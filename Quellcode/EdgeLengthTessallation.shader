/**
* EdgeLengthTessellation-Shader
* 
* Berechnet die Tessellation des Objektes basierend auf der Länge der Kanten der Flächen (Dreiecke).
*
* Autor: Martin Schuster

* Quellen: 
* https://docs.unity3d.com/Manual/SL-SurfaceShaderTessellation.html
* https://github.com/joetex/VoxelGame/blob/master/Assets/Shaders/CGIncludes/Tessellation.cginc
*/

Shader "Custom/EdgeLengthTessellation" { //Gruppierung und Name des Shader
	
	/**
	* Eigenschaften des Shaders, dienen zur beeinflussung des Shaders 
	* und ermöglichen die Interaktion mit Unity.
	*/
	Properties 
	{
		_DiffuseTexture ("Diffuse Texture", 2D) = "white" {} // Texture für den Shader
		_NormalMap ("Normal Map", 2D) = "bump" {} // Beinflusst die Normalenvektoren der Eckpunkte des Objektes für eine akurate beleuchtung
		_DisplacementTexture ("Displacement Texture", 2D) = "gray" {} // Graustufen Textur welche die Eckpunkten entsprechend der werte verschiebt
		_DisplacementFactor ("Displacement Factor", Range(0,1.0)) = 1.0 // Stärke die angibt wie stark die Werte der Displacement Textur verwendet werden
		_EdgeLength ("Edge length", Range(2,50)) = 2 // Kantenlänge die die länge ab der eine Unterteilung stattfindet angibt kleinere Werte bedeuten eine stärkere (feinere) Unterteilung
		_Color ("Color", color) = (1,1,1,0) // Ermöglicht einfärbung der Diffuse Texture
        _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5) // Farbe der Glanzpunkte
	}
	
	/**
	* Mittels des CGINCLUDE Blockes können wieder verwendbare Funktionen dem Shader hinzugefügt werden.
	* 
	*/	
	CGINCLUDE
	    // Berechnet den Unterteilungsfaktor für eine Kante eines Dreiecks
        float CalcEdgeTessFactor (float3 worldposition0, float3 worldposition1, float edgeLength)
        {
            // Distanz der Kante zur Kamera
            float dist = distance(0.5 * (worldposition0+worldposition1), _WorldSpaceCameraPos);
            // Länge der Kante
            float length = distance(worldposition0, worldposition1);
            // Bestimmt den Teilungsfaktor _ScreenParams.y gibt die höhe der Ziel RenderTextur an
            float factor = max((length * _ScreenParams.y / (edgeLength * dist)), 1.0);
            
            return factor;
        }

        // Bekommt die 3 Eckpunkte einer Dreiecksfläche übertragen und berechnet die Koordinatenwerte für die neuen Eckpunkte 
        float4 EdgeLengthBasedTess (float4 vertice0, float4 vertice1, float4 vertice2, float edgeLength)
        {
            // unity_ObjectToWorld gibt an das dass Koordinatensystem des Objektes genutzt wird
            float3 position0 = mul(unity_ObjectToWorld, vertice0).xyz; 
            float3 position1 = mul(unity_ObjectToWorld, vertice1).xyz;
            float3 position2 = mul(unity_ObjectToWorld, vertice2).xyz;
            float4 tessellation;
            
            tessellation.x = CalcEdgeTessFactor(position1, position2, edgeLength);
            tessellation.y = CalcEdgeTessFactor(position2, position0, edgeLength);
            tessellation.z = CalcEdgeTessFactor(position0, position1, edgeLength);
            tessellation.w = (tessellation.x + tessellation.y + tessellation.z) / 3.0f;
            
            return tessellation;
        }
	ENDCG
	
	/**
	* Ab diesem Punkt wird die Funktion des Shader geschrieben.
	* Es können in einem Shader mehrere SubShader geschrieben werden.
	*/
	SubShader {
            Tags { "RenderType"="Opaque" } // Mittels Tags kann die Reienfolge und Art wie und wann das Objekt gerendert wird festgelegt werden (Rendertype Opaque gibt an das es ein Solides Objekt ist)
            
            CGPROGRAM // Ab diesem Punkt wird der Quellcode geschrieben der von GPU ausgeführt wird
            // Angabe der genutzten Funktionen für den Shader
            // surface surfaceFunction: über Funktion von den Hardware nahen vertex und pixel Shader Programmen vereinfacht das erstellen eines Beleuchteten Shader 
            // BlinnPhong: Art der Schattierung
            // addshadow: teilt dem Suraface-Shader mit einen neuen Schatten durchlauf durchzuführen
            // fullforwardshadows: fügt den Schatten dem Shader hinzu
            // vertex:displacement: stellt einen Vertex Shader für das Displacement Mapping zur verfügugn 
            // tessellate:tessellateEdgeLenght: nutzt die tessellate Funktion und gibt ihr den Namen tessellateEdgeLenght
            #pragma surface surfaceFunction BlinnPhong addshadow fullforwardshadows vertex:displacement tessellate:tessellateEdgeLenght nolightmap
            // #pragma target 4.6 gibt die compilierungs Zielversion an dies stellt sicher das Hardware verwendet wird welche die Funktionen unterstützt (OpenGL 4.1 DX11) 
            #pragma target 4.6 
            //ermöglicht das Nutzen von zusätzlichen Funktion
            //#include "Tessellation.cginc" 
            //#include "Tessellation.cginc" 
            
            // Sammlung aller Input Werte in einer Struktur
            struct patchData {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            float _EdgeLength; // Bekanntmachung der Kantenlängen variable für die verwendung im Shader
            
            // Führt die Tessellation aus solange wie neue Eckpunkte für eine Dreiecksfläche vorhanden sind
            float4 tessellateEdgeLenght (patchData vertice0, patchData vertice1, patchData vertice2)
            {
                return EdgeLengthBasedTess(vertice0.vertex, vertice1.vertex, vertice2.vertex, _EdgeLength);            
            }
            
            sampler2D _DisplacementTexture; // Initialisiert die Displacement Textur variable für die verwendung im Shader
            float _DisplacementFactor; // Initialisiert den Displacement Faktor für die verwendung im Shader
            
            /**
            * Führt die verschiebung der Vertices anhand der Displacement Texture und des Displacement Faktors aus.
            * Die eingegebenen Daten aus der patchData Struktur werden auch wieder in diese geschrieben, dies wird durch den inout parameter angegeben.
            * Von der Displacement Texture werden die uv Koordinaten geladen und von diesen der Rotkanalwert mit dem Displacement Faktor multipliziert.
            * Anschließend wird die Position des Eckpunktes entlang des Normalenvektors verschoben.
            */
            void displacement (inout patchData vertice)
            {
                float displaceEffect = tex2Dlod(_DisplacementTexture, float4(vertice.texcoord.xy,0,0)).r * _DisplacementFactor;
                vertice.vertex.xyz += vertice.normal * displaceEffect;
            }
            
            // uv Koordinaten der Diffuse Textur
            struct Input {
                float2 uv_DiffuseTexture;
            };
    
            sampler2D _DiffuseTexture; // Initialisiert die Diffuse Textur für die verwendung im Shader
            sampler2D _NormalMap; // Initialisiert die Normal Map für die verwendung im Shader
            fixed4 _Color;
            
            // Surface Shader Funktion Färbt die Flächen entsprechend ein            
            void surfaceFunction (Input input, inout SurfaceOutput output) {
                float4 c = tex2D (_DiffuseTexture, input.uv_DiffuseTexture) * _Color;
                output.Albedo = c.rgb;
                output.Specular = 0.2;
                output.Gloss = 1.0;
                output.Normal = UnpackNormal(tex2D(_NormalMap, input.uv_DiffuseTexture));
            }
            ENDCG // Ende des Codeblockes
        }
        FallBack "Diffuse" // Wird genutzt wenn fehler im Shader auftreten.
}