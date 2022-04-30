--global variables--
base_morph = $mat.Morpher 
channel_num = #{}
for i=1 to 100 do channel_num[i] = WM3_MC_HasData base_morph i  
channel_num = channel_num as array
name_list = for num in channel_num collect WM3_MC_GetName base_morph num 
get_file
get_wav 
sel_but

--orient view for easier workspace--
if viewport.numViews == 1 do 
(
	--add second view and set layout--  
	viewport.setLayout #layout_2v
	viewport.setType #View_front
	viewport.setType #view_persp_user 
	
	--switch to second viewport and set layout-- 
	viewport.activeViewportEx 1
	viewport.setType #view_left 
	viewport.setType #view_persp_user
	
	)


--functions--
fn open_t_file = 
(
	
	get_file = getOpenFileName \
	types:"text(*.txt)"
	
	)
	
fn open_w_file = 
(
	
	get_wav = getOpenFileName \ 
	types:"wav(*.wav)"
	
	proSound.append get_wav
	
	)

fn delete_w_file = 
(
	
	proSound.delete 1
	
	)
	
fn gen_key_frames = 
(
	
	animButtonState = true 
	
	t_file = openfile get_file 
	
	while not eof t_file do 
	(
		
		read_line = readline t_file 
		filter_string = FilterString read_line " "
		
		t_channel = filter_string [1] as string 
		s_frame = filter_string[2] as time
		e_frame = filter_string[3] as time
		
		c = e_frame - s_frame 
		d = c/2
		m_frame = s_frame + d as time 
		
		for num in channel_num do 
		(
			
			if t_channel == name_list[num] or t_channel == num do 
			(
				
				at time m_frame WM3_MC_SetValue base_morph num 100.00
				
				at time s_frame WM3_MC_SetValue base_morph num 000.00
				at time e_frame WM3_MC_SetValue base_morph num 000.00
				
				)
			
			)
		
		)
	
	)
	
-- create rollout, custom ui--
rollout main_rollout "Morpher Helper" width:200 height:400
(
	
	--input group-- 
	groupBox input_group "Frame Generation" pos:[5, 5] width: 190 height: 125
	button input_txt "Input .txt" align:#left offset:[0, -113.125] width:80
	button input_wav "Input .wav" align:#right offset:[0, -26.5] width:80
	button delete_wav "Delete .wav" align:#center width:175
	button generate_frames "Generate Frames" align:#center width:175 
	button render_sequence "Render Sequence" align:#center width:175
	
	--input group event listeners--
	on input_txt pressed do 
	(
		
		open_t_file()
		
		)
		
	on input_wav pressed do 
	(
		
		open_w_file()
		
		)
		
	on generate_frames pressed do 
	(
		
		gen_key_frames()
		
		)
		
	on delete_wav pressed do 
	(
		
		delete_w_file()
		
		)
	
	--create subrollout and dynamic spinners/buttons for morpher channels-- 
	fn target_sub_ui count = 
	(
		
		local num_rollout = #();
		
		for y = 1 to count do 
		(
			
			local rollout_creator = rolloutCreator "new_rollout" "Morpher Channels" width:400 height:400
			rollout_creator.begin()
			
			for num in channel_num do 
			(
				
				--controllers/handlers for morpher channels--
				spin_name = name_list[num] + num as string 
				rollout_creator.addControl #spinner spin_name "" paramStr:"width: 70 height: 20 align: #right"
				rollout_creator.addHandler spin_name #changed paramStr:"val" codeStr:("WM3_MC_SetValue base_morph " + num as string + " val")
				
				rollout_creator.addControl #button name_list[num] name_list[num] paramStr:"width: 60 height: 20 align: #left offset:[0 , -26.5]"
				rollout_creator.addHandler name_list[num] #pressed filter: on codeStr:("sel_but = " + num as string)
				
				)
			
			--add/delete/reload target controllers/handlers--
			rollout_creator.addControl #button #add_but "Add" paramStr:"width: 150 height: 20 align: #center"
			rollout_creator.addHandler #add_but #pressed filter: on codeStr:"print @Not Implemented.@"
			
			rollout_creator.addControl #button #del_but "Delete" paramStr:"width: 150 height: 20 align: #center"
			rollout_creator.addHandler #del_but #pressed filter: on codeStr:"@Not Implemented.@"
			
			rollout_creator.addControl #button #rel_but "Reload" paramStr:"width: 150 height: 20 align: #center"
			rollout_creator.addHandler #rel_but #pressed filter: on codeStr:"print @Not Implemented.@"
			
			rollout_creator.end()
			append num_rollout rollout_creator.def 
			
			)
			
		return num_rollout;
		
		)
		
	subRollout morph_sub "morph_sub" height: 400 width: 190 offset:[0, 10] align: #center
	
	on main_rollout open do 
	(
		
		for ro in target_sub_ui 1 do 
			
			AddSubRollout morph_sub ro rolledUp: false 
		
		)
	
	)

--create dialog and anchor to user interface--	
CreateDialog main_rollout 
cui.registerDialogBar main_rollout style:#(#cui_dock_left, #cui_floatable, #cui_dock_left)
cui.dockDialogBar main_rollout #cui_dock_left
	