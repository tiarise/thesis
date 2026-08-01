extends Node2D


var mMusicSounds = []

var mCurrent_music = 0



func _ready():
	PrepareMusicPlaylist()


#This puts all music tracks into an array.
func PrepareMusicPlaylist():
		mMusicSounds.clear()
		mCurrent_music = 0
		for track in get_node("/root/SceneRoot/Sounds/Music").get_children():
			mMusicSounds.append(track)


#The enviormental effects are a special subgroup of worldsounds.
#Globally their voume can be set trought the WorldSounds, since they are world sounds.
#And they can be started along the world sounds with StartSounds("WorldSounds_NormalSounds) and
#StartSounds("WorldSounds_TimedSounds), but they can be turned off after the save file is loaded
func StartEnviormentalEffectSounds():
	#This is special 'cos this can be turned off. This only starts if the toggle button is on.
		var EnviormentalEffectsSounds = get_tree().get_nodes_in_group("EnviormentalEffectSounds")
		for sound in EnviormentalEffectsSounds:
				if( sound.is_type("StreamPlayer") ): 
					sound.play()
				else: 
					pass 

func StopEnviormentalEffectSounds():
		var EnviormentalEffectsSounds = get_tree().get_nodes_in_group("EnviormentalEffectSounds")
		for sound in EnviormentalEffectsSounds:
				if( sound.is_type("StreamPlayer") ): 
					sound.stop()
				else:
					pass 


#This is needed 'cos StartSounds with World sounds starts the WorldSounds subtype 
#EnviormentalEffectsSounds too even is the toggle button is off, this ensures this would not happen,
#by turning it off immediately. 
func CheckEnviormentalEffectState():
	if ( get_node("/root/GameCore").Video_GameEffects ):
		StartEnviormentalEffectSounds()
	else:
		StopEnviormentalEffectSounds()



#You have to give the objectname and the Soundtype witch is basicly the parentnode( MiscSounds for example )
#If what you call is a WorldSound you need to give the subtype too.
#If it is a sample the you have to give the sample name too.
func StartSound(objectName,soundType,isSample,sampleName = ""):
	if ( objectName != "" ):
		if( soundType != "" ):
			if isSample == false :
				get_node(soundType + "/" + objectName).play()
			else:
				get_node(soundType + "/" + objectName).play(sampleName)

#Stop/Play a steam or a sample (class required like MiscSounds )
func StopSound(objectName,soundType,isSample,sampleName = ""):
	if ( objectName != "" ):
		if( soundType != "" ):
			if isSample == false :
				get_node(soundType + "/" + objectName).stop()
			else:
				get_node(soundType + "/" + objectName).stop(sampleName)
					
#Misc sounds do not started on purpose :) those are for different things.
func StartSounds(groupname = ""):
		#This means no parameter so, start all known element in WorldSounds group 
		#and start first track in Music group.
		if( groupname == "" ):
			#Start the TimedSounds in WorldSounds
			var WorldSounds_TimedSounds = get_tree().get_nodes_in_group("WorldSounds_TimedSounds")
			for timedSound in WorldSounds_TimedSounds:
				timedSound.get_node("Timer").start()
				
			#Start the NormalSounds in WorldSounds
			var WorldSounds_ConstantSounds = get_tree().get_nodes_in_group("WorldSounds_ConstantSounds")
			for sound in WorldSounds_ConstantSounds:
				#In theory one should only put stream player here, just in case we check..
				if( sound.is_type("StreamPlayer") ):  
					sound.play()
					
			#Start first Music track
			if !mMusicSounds[mCurrent_music].is_playing():
				mMusicSounds[mCurrent_music].play()
			
		else:
			#This means we got a specific group call
			if( groupname == "WorldSounds_TimedSounds" ):
				var WorldSounds_TimedSounds = get_tree().get_nodes_in_group("WorldSounds_TimedSounds")
				for timedSound in WorldSounds_TimedSounds:
					timedSound.get_node("Timer").start()
					
			elif ( groupname == "WorldSounds_ConstantSounds" ):
				var WorldSounds_ConstantSounds = get_tree().get_nodes_in_group("WorldSounds_ConstantSounds")
				for sound in WorldSounds_ConstantSounds:
					#In theory one should only put stream player here, just in case we check..
					if( sound.is_type("StreamPlayer") ):  
						sound.play()
			
			elif( groupname == "MusicSounds" ):
				mMusicSounds[mCurrent_music].play()
				
		CheckEnviormentalEffectState() #Read Above.

#Misc sounds do not stopped on purpose :) those are for different things.
func StopSounds(groupname = ""):

		#This means no parameter so, start all known element in WorldSounds group 
		#and start first track in Music group.
		if( groupname == "" ):
			#Start the TimedSounds in WorldSounds
			var WorldSounds_TimedSounds = get_tree().get_nodes_in_group("WorldSounds_TimedSounds")
			for timedSound in WorldSounds_TimedSounds:
				timedSound.get_node("Timer").stop()
				
			#Start the NormalSounds in WorldSounds
			var WorldSounds_ConstantSounds = get_tree().get_nodes_in_group("WorldSounds_ConstantSounds")
			for sound in WorldSounds_ConstantSounds:
				#In theory one should only put stream player here, just in case we check..
				if( sound.is_type("StreamPlayer") ):  
					sound.stop()
					
			#Start first MUsic track
			mMusicSounds[mCurrent_music].stop()
			
		else:
			#This means we got a specific group call
			if( groupname == "WorldSounds_TimedSounds" ):
				var WorldSounds_TimedSounds = get_tree().get_nodes_in_group("WorldSounds_TimedSounds")
				for timedSound in WorldSounds_TimedSounds:
					timedSound.get_node("Timer").stop()
					
			elif ( groupname == "WorldSounds_ConstantSounds" ):
				var WorldSounds_ConstantSounds = get_tree().get_nodes_in_group("WorldSounds_ConstantSounds")
				for sound in WorldSounds_ConstantSounds:
					#In theory one should only put stream player here, just in case we check..
					if( sound.is_type("StreamPlayer") ):  
						sound.stop()
			
			elif( groupname == "MusicSounds" ):
				mMusicSounds[mCurrent_music].play()
						

func SetVolume(value,groupName = ""):
	#If there is at least a groupname( WorldSounds,MiscSounds,MusicSounds ) or node name
	if ( groupName != "" ):
		var baseDB = -60
		var masterModifier = get_node("/root/GameCore").Sound_MasterVolume
		masterModifier = (60-((masterModifier)*0.6)) #If master is on 100 this converts it to 0 to 60 from 0 to 100 
		                                             #But in inverse, if master slider is 100 then this is 0 if 0 then this is 60
		
		#Check the group names if there was no full path
		if( groupName == "WorldSounds_ConstantSounds" ):
			GameCore.Sound_EnvironmentVolume = value
			
			#We have to adjust the value from 1-100(slider) to db(-60 to 0 )
			value = (value)*0.6
			
			var WorldSounds_ConstantSounds = get_tree().get_nodes_in_group("WorldSounds_ConstantSounds")
			for i in range( WorldSounds_ConstantSounds.size() ): #No prob if stream is not in sample player then it is ignored and vica versa
				WorldSounds_ConstantSounds[i].set("params/volume_db",baseDB+value-masterModifier) 
				WorldSounds_ConstantSounds[i].set("stream/volume_db",baseDB+value-masterModifier)
				
				
		elif( groupName == "WorldSounds_TimedSounds" ):
			GameCore.Sound_EnvironmentVolume = value
			
			#We have to adjust the value from 1-100(slider) to db(-60 to 0 )
			value = (value)*0.6
			
			var WorldSounds_TimedSounds = get_tree().get_nodes_in_group("WorldSounds_TimedSounds")
			for i in range( WorldSounds_TimedSounds.size() ):
				WorldSounds_TimedSounds[i].set("params/volume_db",baseDB+value-masterModifier)
				WorldSounds_TimedSounds[i].set("stream/volume_db",baseDB+value-masterModifier)
				
				
		elif( groupName == "MiscSounds" ):
			
			#We have to adjust the value from 1-100(slider) to db(-60 to 0 )
			value = (value)*0.6
			
			var MiscSounds = get_tree().get_nodes_in_group("MiscSounds")
			for i in range( MiscSounds.size() ):
				MiscSounds[i].set("params/volume_db",baseDB+value-masterModifier)
				MiscSounds[i].set("stream/volume_db",baseDB+value-masterModifier)
				
		elif( groupName == "MusicSounds" ):
			GameCore.Sound_MusicVolume = value
			
			#We have to adjust the value from 1-100(slider) to db(-60 to 0 )
			value = (value)*0.6
			
			for i in range( mMusicSounds.size() ):
				mMusicSounds[i].set("params/volume_db",baseDB+value-masterModifier)
				mMusicSounds[i].set("stream/volume_db",baseDB+value-masterModifier)
	
	#This means we have to set the master
	else:
		get_node("/root/GameCore").Sound_MasterVolume = value
		
		#Re adjust the whole stuff.( Only the music can be set now and the master  so others 100)
		self.SetVolume(GameCore.Sound_EnvironmentVolume,"WorldSounds_ConstantSounds")
		self.SetVolume(GameCore.Sound_EnvironmentVolume,"WorldSounds_TimedSounds")
		self.SetVolume(100,"MiscSounds")
		self.SetVolume(GameCore.Sound_MusicVolume,"MusicSounds")
		
#THis starts nodes.
func _Signal_StepMusicTrack():
	mCurrent_music = mCurrent_music +1
	if( mMusicSounds.size()-1 >= mCurrent_music ): # if there is a track numbered next. -1 cos it starts from 0
		mMusicSounds[mCurrent_music].play()
	else: # If not start over.
		mCurrent_music = 0
		mMusicSounds[mCurrent_music].play()