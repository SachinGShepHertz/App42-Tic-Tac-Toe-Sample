module(..., package.seeall)
local function newButtonHandler( self, event )

	local result = true

	local default = self[1]
	local over = self[2]
	local onEvent = self._onEvent
	
	local onPress = self._onPress
	local onRelease = self._onRelease

	local buttonEvent = {}
	if (self._id) then
		buttonEvent.id = self._id
	end

	local phase = event.phase
	if "began" == phase then
		if over then 
			default.isVisible = false
			over.isVisible = true
		end

		if onEvent then
			buttonEvent.phase = "press"
			result = onEvent( buttonEvent )
		elseif onPress then
			result = onPress( event )
		end
		display.getCurrentStage():setFocus( self, event.id )
		self.isFocus = true
		
	elseif self.isFocus then
		local bounds = self.stageBounds
		local x,y = event.x,event.y
		local isWithinBounds = 
			bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y

		if "moved" == phase then
			if over then
				default.isVisible = not isWithinBounds
				over.isVisible = isWithinBounds
			end
			
		elseif "ended" == phase or "cancelled" == phase then 
			if over then 
				default.isVisible = true
				over.isVisible = false
			end
			
			if "ended" == phase then
				if isWithinBounds then
					if onEvent then
						buttonEvent.phase = "release"
						result = onEvent( buttonEvent )
					elseif onRelease then
						result = onRelease( event )
					end
				end
			end
			
			display.getCurrentStage():setFocus( self, nil )
			self.isFocus = false
		end
	end

	return result
end

function newButton( params )
	local button, default, over, size, font, textColor, offset
	
	if params.default then
		button = display.newGroup()
		default = display.newImage( params.default )
		button:insert( default, true )
	end
	
	if params.over then
		over = display.newImage( params.over )
		over.isVisible = false
		button:insert( over, true )
	end
	
	-- Public methods
	function button:setText( newText )
	
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
	end
	
	if params.text then
		button:setText( params.text )
	end
	
	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
		
	button.touch = newButtonHandler
	button:addEventListener( "touch", button )

	if params.x then
		button.x = params.x
	end
	
	if params.y then
		button.y = params.y
	end
	
	if params.id then
		button._id = params.id
	end

	return button
end

function newLabel( params )
	local labelText
	local size, font, textColor, align
	local t = display.newGroup()
	
	if ( params.bounds ) then
		local bounds = params.bounds
		local left = bounds[1]
		local top = bounds[2]
		local width = bounds[3]
		local height = bounds[4]
	
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		if ( params.align ) then align = params.align else align = "center" end
		
		if ( params.text ) then
			labelText = display.newText( params.text, 0, 0, font, size )
			labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
			t:insert( labelText )
	
			if ( align == "left" ) then
				labelText.x = left + labelText.stageWidth * 0.5
			elseif ( align == "right" ) then
				labelText.x = (left + width) - labelText.stageWidth * 0.5
			else
				labelText.x = ((2 * left) + width) * 0.5
			end
		end
		
		labelText.y = top + labelText.stageHeight * 0.5

		function t:setText( newText )
			if ( newText ) then
				labelText.text = newText
				
				if ( "left" == align ) then
					labelText.x = left + labelText.stageWidth / 2
				elseif ( "right" == align ) then
					labelText.x = (left + width) - labelText.stageWidth / 2
				else
					labelText.x = ((2 * left) + width) / 2
				end
			end
		end
		
		function t:setTextColor( r, g, b, a )
			local newR = 255
			local newG = 255
			local newB = 255
			local newA = 255

			if ( r and type(r) == "number" ) then newR = r end
			if ( g and type(g) == "number" ) then newG = g end
			if ( b and type(b) == "number" ) then newB = b end
			if ( a and type(a) == "number" ) then newA = a end

			labelText:setTextColor( r, g, b, a )
		end
	end
	return t
	
end