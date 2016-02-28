
// sky:

textures/tabd2map01/lun_nubiansky2
{
	surfaceparm noimpact
	surfaceparm nolightmap
	//q3map_sun 1 .9 .8 30 300 60
	q3map_sun 1 .95 .85 60 150 75	// ele 50,70; deg120	// r g b int degr elev
	q3map_surfacelight 90		// was 110
	q3map_lightimage textures/base_light/light5.tga
	qer_editorimage textures/tabd2map01/tab_fx_yellow.tga
	skyparms env/lun4tab 768 -
	{
		map textures/tabd2map01/lun_nubian5.tga
		tcMod scale 4 4
		tcMod scroll 0.03 0.03
		blendFunc add
	}
}

// fog:
textures/tabd2map01/fog_green_a
{
	qer_editorimage textures/tabd2map01/fog_green.tga
	surfaceparm	trans
	surfaceparm	nonsolid
	surfaceparm	fog
	surfaceparm nodrop
	surfaceparm nolightmap
	q3map_globaltexture
	fogparms ( .5 .5 0 ) 6000.0

	{
		map textures/liquids/kc_fogcloud3.tga
		blendfunc gl_dst_color gl_zero
		tcmod scale -.05 -.05
		tcmod scroll -.02 .02
		rgbgen identity
	}
	{
		map textures/liquids/kc_fogcloud3.tga
		blendfunc gl_dst_color gl_zero
		tcmod scale .05 .05
		tcmod scroll -.02 .02
		rgbgen identity
	}

}

textures/tabd2map01/tab_water
{
	qer_editorimage textures/tabd2map01/tab_water.tga
	qer_trans .5
	q3map_globaltexture
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water

	cull disable
	//tesssize 64		// is dit ok?
	deformVertexes wave 64 sin .25 .25 0 .5	

		{ 
			map textures/liquids/pool3d_5c2.tga
			blendFunc GL_dst_color GL_zero
			rgbgen identity
			tcmod scale .5 .5
			tcmod transform 1.5 0 1.5 1 1 2
			tcmod scroll -.05 .001
		}	
		{ 
			map textures/liquids/pool3d_3c2.tga
			blendFunc GL_dst_color GL_zero
			rgbgen identity
			tcmod scale .25 .5
			tcmod scroll .001 .025
		}
	{ 
		map textures/tabd2map01/tab_water.tga
		blendFunc add
		rgbgen identity
		tcmod scale .5 .5
		tcmod turb 0.1 0.01 0 0.1
	}
}


textures/tabd2map01/sprite_grass1
{
	qer_editorimage textures/tabd2map01/sprite_grass1.tga
	//q3map_vertexScale 2
	qer_alphafunc greater 0.5
	surfaceparm alphashadow
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nomarks
	qer_trans 0.99
      cull none
	nopicmip
      {
		map textures/tabd2map01/sprite_grass1.tga
            blendFunc GL_ONE GL_ZERO
            alphaFunc GE128
            depthWrite
            rgbGen identity
      }
      {
            map $lightmap
            rgbGen identity
            blendFunc GL_DST_COLOR GL_ZERO
      	depthFunc equal
	}
}

textures/tabd2map01/sprite_grass3
{
	qer_editorimage textures/tabd2map01/sprite_grass3.tga
	qer_alphafunc greater 0.5
	surfaceparm alphashadow
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nomarks
	qer_trans 0.99
	cull none
	nopicmip
	{
		map textures/tabd2map01/sprite_grass3.tga
            blendFunc GL_ONE GL_ZERO
            alphaFunc GE128
            depthWrite
            rgbGen identity
      }
      {
            map $lightmap
            rgbGen identity
            blendFunc GL_DST_COLOR GL_ZERO
      	depthFunc equal
	}
}



// --------------------------------------------------
// TAB's OWN TEXTURES
// --------------------------------------------------

textures/tabd2map01/q3_roof_02
{
	qer_editorimage textures/tabd2map01/q3_roof_02.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/q3_roof_02.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/q3_roof_02_blend.tga
		blendfunc add
	}
}

textures/tabd2map01/tab_windowlight
{
	qer_editorimage textures/tabd2map01/tab_windowlight.tga
	surfaceparm nomarks
	surfaceparm metalsteps
	q3map_surfacelight 7500
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_windowlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_windowlight_blend.tga
		blendfunc add
		//rgbgen wave noise 0.2 0.1 0 5
	}
}

textures/tabd2map01/tab_tekgrn_05_light
{
	qer_editorimage textures/tabd2map01/tab_tekgrn_05_light.tga
	surfaceparm nomarks
	q3map_surfacelight 1000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_tekgrn_05_light.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_tekgrn_05_light_blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tabd2map01/tab_tekgrn_05_light_500
{
	qer_editorimage textures/tabd2map01/tab_tekgrn_05_light.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_tekgrn_05_light.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_tekgrn_05_light_blend.tga
		blendfunc GL_ONE GL_ONE
	}
}


textures/tabd2map01/tab_ceil1_2
{
	qer_editorimage textures/tabd2map01/tab_ceil1_2.tga
	q3map_lightimage textures/tabd2map01/tab_fx_yellow.tga
	q3map_surfacelight 3000
	light 1
	surfaceparm nomarks
	surfaceparm metalsteps
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_2.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_2_blend.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave noise 0.2 0.1 0 5
	}
}

textures/tabd2map01/tab_ceil1_3
{
	qer_editorimage textures/tabd2map01/tab_ceil1_3.tga
	q3map_lightimage textures/tabd2map01/tab_fx_yellow.tga
	q3map_surfacelight 3000
	light 1
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_3.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_2_blend.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave noise 0.2 0.1 0 5
	}
}

textures/tabd2map01/tab_ceil1_2b
{
	qer_editorimage textures/tabd2map01/tab_ceil1_2.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_2.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_2_blend.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave noise 0.2 0.1 0 5
	}
}

textures/tabd2map01/tab_ceil1_3b
{
	qer_editorimage textures/tabd2map01/tab_ceil1_3.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_3.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ceil1_2_blend.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave noise 0.2 0.1 0 5
	}
}


textures/tabd2map01/tab_exit_sign
{
	qer_editorimage textures/tabd2map01/tab_exit_sign_blend.tga
	surfaceparm nomarks
	q3map_surfacelight 100
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_exit_sign.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_exit_sign_blend.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave noise 0.2 0.1 0 10
	}
}

textures/tabd2map01/tab_button1
{
	qer_editorimage textures/tabd2map01/tab_button1.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_button1.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_button1_blend.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave triangle 1 3 1 .5
	}
}

textures/tabd2map01/tab_button2
{
	qer_editorimage textures/tabd2map01/tab_button2.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_button2.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_button2_blend1.tga
		blendfunc add
		rgbGen wave triangle 1 3 1 .5
	}
}

textures/tabd2map01/tab_button2b
{
	qer_editorimage textures/tabd2map01/tab_button2b.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_button2b.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_button2_blend2.tga
		blendfunc add
		rgbGen wave triangle 1 3 1 .6
	}
}



// --------------------------------------------------
// TAB's ADAPTATION OF OTHER TEXTURES
// --------------------------------------------------

textures/tabd2map01/tab_pjgrate2
{
	qer_editorimage textures/tabd2map01/tab_pjgrate2.tga
	//qer_trans .6
	surfaceparm trans
	surfaceparm nomarks
	//surfaceparm alphashadow // te donker?
	cull none
	nopicmip
	{
		map textures/tabd2map01/tab_pjgrate2.tga
		//tcMod scale 2.0 2.0
		blendFunc GL_ONE GL_ZERO
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

// -------------------------------------------------------
// adjustment of Q3 lights
// -------------------------------------------------------

textures/tabd2map01/q3_ceil1_4_6k
{
	qer_editorimage textures/base_light/ceil1_4.tga
	surfaceparm nomarks
	q3map_surfacelight 6000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_4.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_4.blend.tga
		blendfunc GL_ONE GL_ONE
	}
}
textures/tabd2map01/q3_ceil1_4_4k
{
	qer_editorimage textures/base_light/ceil1_4.tga
	surfaceparm nomarks
	q3map_surfacelight 4000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_4.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_4.blend.tga
		blendfunc GL_ONE GL_ONE
	}
}
textures/tabd2map01/q3_ceil1_4_2k
{
	qer_editorimage textures/base_light/ceil1_4.tga
	surfaceparm nomarks
	q3map_surfacelight 2000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_4.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_4.blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tabd2map01/q3_xceil1_nolight
{
	// no surface light, base for spotlight use
	qer_editorimage textures/base_light/ceil1_39.tga
	surfaceparm nomarks
	// Square dirty white
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_39.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_39.blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tabd2map01/q3_ceil122a_nolight
{
	// no surface light, base for spotlight use
	qer_editorimage textures/base_light/ceil1_22a.tga
	surfaceparm nomarks
	// Square dirty white
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_22a.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_22a.blend.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/tabd2map01/q3_ceil_white2k
{
	qer_editorimage textures/base_light/ceil1_38.tga
	surfaceparm nomarks
	q3map_surfacelight 2000
	light 1
	// Square dirty white llight
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_38.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/base_light/ceil1_38.blend.tga
		blendfunc GL_ONE GL_ONE
	}
}


// ======================================================================
// Sock's DotProduct2 Terrain blending
// ======================================================================

textures/tabd2map01/ter_dirtgrass
{
      qer_editorimage textures/tabd2map01/ter_dirtgrass.tga
	
	surfaceparm nosteps	// it's grassy
	q3map_nonplanar
	//q3map_shadeangle 120
	q3map_shadeangle 45
	q3map_tcGen ivector ( 256 0 0 ) ( 0 256 0 )
	q3map_alphaMod dotproduct2 ( 0.0 0.0 0.8 )
	{
		map textures/tabd2map01/tab_grass_00.tga	// Primary
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ter_mud.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		//alphaFunc GE128
		rgbGen identity
		alphaGen vertex
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}


textures/tabd2map01/ter_sandgrass
{
      qer_editorimage textures/tabd2map01/ter_sandgrass.tga
	
	surfaceparm nosteps	// it's sandy
	q3map_nonplanar
	q3map_shadeangle 45
	q3map_tcGen ivector ( 256 0 0 ) ( 0 256 0 )
	q3map_alphaMod dotproduct2 ( 0.0 0.0 0.8 )
	{
		map textures/tabd2map01/tab_grass_00.tga	// Primary
		rgbGen identity
	}
	{
		map textures/tabd2map01/tab_ter_sand.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		//alphaFunc GE128
		rgbGen identity
		alphaGen vertex
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}


// ======================================================================
// alpha fade shaders
// (c) 2004 randy reddig
// http://www.shaderlab.com
// ======================================================================

textures/tabd2map01/alpha_000	// Primary texture ONLY
{
	q3map_alphaMod volume
	q3map_alphaMod set 0
	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm trans
	qer_trans 0.75
}

textures/tabd2map01/alpha_025
{
	q3map_alphaMod volume
	q3map_alphaMod set 0.25
	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm trans
	qer_trans 0.75
}

textures/tabd2map01/alpha_050	// Perfect mix of both Primary + Secondary
{
	q3map_alphaMod volume
	q3map_alphaMod set 0.50
	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm trans
	qer_trans 0.75
}

textures/tabd2map01/alpha_075
{
	q3map_alphaMod volume
	q3map_alphaMod set 0.75
	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm trans
	qer_trans 0.75
}

textures/tabd2map01/alpha_085
{
	q3map_alphaMod volume
	q3map_alphaMod set 0.85
	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm trans
	qer_trans 0.75
}

textures/tabd2map01/alpha_100	// Secondary texture ONLY
{
	q3map_alphaMod volume
	q3map_alphaMod set 1.0
	surfaceparm nodraw
	surfaceparm nonsolid
	surfaceparm trans
	qer_trans 0.75
}



// --------------------------------------------------
// LUNARAN TEXTURES (LUN3DM4)
// --------------------------------------------------

//  Lun3DM4 Shaders -- 04.15.03
//  Feel free to modify and use.  


textures/tabd2map01_lun3dm4/litpan1_flik
{
	qer_editorimage textures/tabd2map01_lun3dm4/litpan1.tga
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun3dm4/litpan1.tga
		blendFunc GL_DST_COLOR GL_ZERO
	}
	{
		map textures/tabd2map01_lun3dm4/litpan1fx.tga
		blendFunc GL_ONE GL_ONE
//		rgbGen wave noise -.6 1.6 180 5.5
		rgbGen wave noise -.4 1.2 450 8
//		rgbGen wave noise -.6 1.6 1800 6

	}
}

textures/tabd2map01_lun3dm4/litpan1_1000
{
	qer_editorimage textures/tabd2map01_lun3dm4/litpan1.tga
	q3map_lightimage textures/tabd2map01_lun3dm4/litpan1fx.tga
	surfaceparm nomarks
	q3map_surfacelight 500
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun3dm4/litpan1.tga
		blendFunc GL_DST_COLOR GL_ZERO
	}
	{
		map textures/tabd2map01_lun3dm4/litpan1fx.tga
		blendFunc GL_ONE GL_ONE
		rgbGen wave sin 0.8 0.1 0 0.1
	}
}


textures/tabd2map01_lun3dm4/litpan1_2000
{
	qer_editorimage textures/tabd2map01_lun3dm4/litpan1.tga
	q3map_lightimage textures/tabd2map01_lun3dm4/litpan1fx.tga
	surfaceparm nomarks
	q3map_surfacelight 2000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun3dm4/litpan1.tga
		blendFunc GL_DST_COLOR GL_ZERO
	}
	{
		map textures/tabd2map01_lun3dm4/litpan1fx.tga
		blendFunc GL_ONE GL_ONE
		rgbGen wave sin 0.8 0.1 0 0.1
	}
}

textures/tabd2map01_lun3dm4/goth1_2000
{
	qer_editorimage textures/tabd2map01_lun3dm4/goth1.tga
	q3map_lightimage textures/tabd2map01_lun3dm4/goth1blend.tga
	surfaceparm nomarks
	q3map_surfacelight 2000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun3dm4/goth1.tga
		blendFunc GL_DST_COLOR GL_ZERO
	}
	{
		map textures/tabd2map01_lun3dm4/goth1blend.tga
		blendFunc GL_ONE GL_ONE
		rgbGen wave sin 0.7 0.3 0 0.1
	}
}

textures/tabd2map01_lun3dm4/proto1_1000
{
	qer_editorimage textures/tabd2map01_lun3dm4/proto1.tga
	q3map_lightimage textures/tabd2map01_lun3dm4/proto1blend.tga
	surfaceparm nomarks
	q3map_surfacelight 1000
	light 1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun3dm4/proto1.tga
		blendFunc GL_DST_COLOR GL_ZERO

		rgbGen identity
	}
	{	
		map textures/tabd2map01_lun3dm4/proto1blend.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .75 0.25 0 .1
	}
	{	
		map textures/tabd2map01_lun3dm4/proto1fx.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave noise 0.2 0.1 0 12
	}
}


// --------------------------------------------------
// LUNARAN TEXTURES (MKSTEEL)
// --------------------------------------------------

// -- New and Improved - 100% Doom Computer Textures
// -- Just like the chainsaw maze from E1M2! :D

textures/tabd2map01_lun/comp3_1
{
	qer_editorimage textures/tabd2map01_lun/comp3.tga
	{
		map textures/tabd2map01_lun/doomfx1.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/tabd2map01_lun/comp3.tga
		blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun/comp3fx1.tga
		blendFunc GL_ONE GL_ONE
		rgbGen identity
	}
}

textures/tabd2map01_lun/comp3_2
{
	qer_editorimage textures/tabd2map01_lun/comp3.tga
	{
		map textures/tabd2map01_lun/doomfx1.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/tabd2map01_lun/comp3.tga
		blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun/comp3fx2.tga
		blendFunc GL_ONE GL_ONE
		rgbGen identity
	}
}

textures/tabd2map01_lun/comp3_3
{
	qer_editorimage textures/tabd2map01_lun/comp3.tga
	{
		map textures/tabd2map01_lun/doomfx1.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/tabd2map01_lun/comp3.tga
		blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun/comp3fx3.tga
		blendFunc GL_ONE GL_ONE
		rgbGen identity
	}
}

textures/tabd2map01_lun/comp3_4
{
	qer_editorimage textures/tabd2map01_lun/comp3.tga
	{
		map textures/tabd2map01_lun/doomfx1.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/tabd2map01_lun/comp3.tga
		blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun/comp3fx4.tga
		blendFunc GL_ONE GL_ONE
		rgbGen identity
	}
}

textures/tabd2map01_lun/comp3_5
{
	qer_editorimage textures/tabd2map01_lun/comp3.tga
	{
		map textures/tabd2map01_lun/doomfx1.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/tabd2map01_lun/comp3.tga
		blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/tabd2map01_lun/comp3fx5.tga
		blendFunc GL_ONE GL_ONE
		rgbGen identity
	}
}

textures/tabd2map01_lun/compblue1
{	{	map textures/tabd2map01_lun/doomfx1.tga
		rgbGen identity
		tcGen environment	}
	{	map textures/tabd2map01_lun/compblue1.tga
		blendFunc GL_ONE GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity	}
	{	map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
}	}

