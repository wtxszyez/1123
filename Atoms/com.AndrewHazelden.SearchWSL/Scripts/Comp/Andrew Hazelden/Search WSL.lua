--[[--
SearchWSL v1 - 2019-05-28
By Andrew Hazelden
--]]--

platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

function OpenURL(siteName, path)
	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. path .. '"'
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. path .. '" &'
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'xdg-open "' .. path .. '" &'
	else
		print('[Error] There is an invalid Fusion platform detected.')
		return
	end
	
	os.execute(command)
	-- print('[Launch Command] ', command)
	print('[Opening URL] [' .. siteName .. '] ' .. path)
end

function EncodeHTML(txt)
	if txt ~= nil then
		htmlCharacters = {
			{pattern = '&', replace = '%26'},
			{pattern = '@', replace = '%40'},
			{pattern = ' ', replace = '+'},
			{pattern = '¡', replace = '&iexcl;'},
			{pattern = '¿', replace = '&iquest;'},
			{pattern = '·', replace = '&middot;'},
			{pattern = '«', replace = '&laquo;'},
			{pattern = '»', replace = '&raquo;'},
			{pattern = '〈', replace = '&#x3008;'},
			{pattern = '〉', replace = '&#x3009;'},
			{pattern = '§', replace = '&sect;'},
			{pattern = '¶', replace = '&para;'},
			{pattern = '%[', replace = '&#91;'},
			{pattern = '%]', replace = '&#93;'},
			{pattern = '‰', replace = '&permil;'},
			{pattern = '†', replace = '&dagger;'},
			{pattern = '‡', replace = '&Dagger;'},
			{pattern = '¨', replace = '&uml;'},
			{pattern = '°', replace = '&deg;'},
			{pattern = '©', replace = '&copy;'},
			{pattern = '®', replace = '&reg;'},
			{pattern = '∇', replace = '&nabla;'},
			{pattern = '∈', replace = '&isin;'},
			{pattern = '∉', replace = '&notin;'},
			{pattern = '∋', replace = '&ni;'},
			{pattern = '±', replace = '&plusmn;'},
			{pattern = '÷', replace = '&divide;'},
			{pattern = '×', replace = '&times;'},
			{pattern = '≠', replace = '&ne;'},
			{pattern = '¬', replace = '&not;'},
			{pattern = '√', replace = '&radic;'},
			{pattern = '∞', replace = '&infin;'},
			{pattern = '∠', replace = '&ang;'},
			{pattern = '∧', replace = '&and;'},
			{pattern = '∨', replace = '&or;'},
			{pattern = '∩', replace = '&cap;'},
			{pattern = '∪', replace = '&cup;'},
			{pattern = '∫', replace = '&int;'},
			{pattern = '∴', replace = '&there4;'},
			{pattern = '≅', replace = '&cong;'},
			{pattern = '≈', replace = '&asymp;'},
			{pattern = '≡', replace = '&equiv;'},
			{pattern = '≤', replace = '&le;'},
			{pattern = '≥', replace = '&ge;'},
			{pattern = '⊂', replace = '&sub;'},
			{pattern = '⊄', replace = '&nsub;'},
			{pattern = '⊃', replace = '&sup;'},
			{pattern = '⊆', replace = '&sube;'},
			{pattern = '⊇', replace = '&supe;'},
			{pattern = '⊕', replace = '&oplus;'},
			{pattern = '⊗', replace = '&otimes;'},
			{pattern = '⊥', replace = '&perp;'},
			{pattern = '◊', replace = '&loz; '},
			{pattern = '♠', replace = '&spades;'},
			{pattern = '♣', replace = '&clubs;'},
			{pattern = '♥', replace = '&hearts;'},
			{pattern = '♦', replace = '&diams;'},
			{pattern = '¤', replace = '&curren;'},
			{pattern = '¢', replace = '&cent;'},
			{pattern = '£', replace = '&pound;'},
			{pattern = '¥', replace = '&yen;'},
			{pattern = '€', replace = '&euro;'},
			{pattern = '¹', replace = '&sup1;'},
			{pattern = '½', replace = '&frac12;'},
			{pattern = '¼', replace = '&frac14;'},
			{pattern = '²', replace = '&sup2;'},
			{pattern = '³', replace = '&sup3;'},
			{pattern = '¾', replace = '&frac34;'},
			{pattern = 'ª', replace = '&ordf;'},
			{pattern = 'ƒ', replace = '&fnof;'},
			{pattern = '™', replace = '&trade;'},
			{pattern = 'β', replace = '&beta;'},
			{pattern = 'Δ', replace = '&Delta;'},
			{pattern = 'ϑ', replace = '&thetasym;'},
			{pattern = 'Θ', replace = '&Theta;'},
			{pattern = 'ι', replace = '&iota;'},
			{pattern = 'λ', replace = '&lambda;'},
			{pattern = 'Λ', replace = '&Lambda;'},
			{pattern = 'μ', replace = '&mu;'},
			{pattern = 'µ', replace = '&micro;'},
			{pattern = 'ξ', replace = '&xi;'},
			{pattern = 'Ξ', replace = '&Xi;'},
			{pattern = 'π', replace = '&pi;'},
			{pattern = 'ϖ', replace = '&piv;'},
			{pattern = 'Π', replace = '&Pi;'},
			{pattern = 'ρ', replace = '&rho;'},
			{pattern = 'σ', replace = '&sigma;'},
			{pattern = 'ς', replace = '&sigmaf;'},
			{pattern = 'Σ', replace = '&Sigma;'},
			{pattern = 'τ', replace = '&tau;'},
			{pattern = 'υ', replace = '&upsilon;'},
			{pattern = 'ϒ', replace = '&upsih;'},
			{pattern = 'φ', replace = '&phi;'},
			{pattern = 'Φ', replace = '&Phi;'},
			{pattern = 'χ', replace = '&chi;'},
			{pattern = 'ψ', replace = '&psi;'},
			{pattern = 'Ψ', replace = '&Psi;'},
			{pattern = 'ω', replace = '&omega;'},
			{pattern = 'Ω', replace = '&Omega;'},
		}

		for i,val in ipairs(htmlCharacters) do
			txt = string.gsub(txt, htmlCharacters[i].pattern, htmlCharacters[i].replace)
		end
	end

	return txt
end

function Search()
	-- Load UI Manager
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	
	-- Create a new window
	local width,height = 523,38
	local x,y = 300, 100
	local win = disp:AddWindow({
		ID = 'SearchWin',
		TargetID = 'SearchWin',
		WindowTitle = 'Search WSL',
		Geometry = {x, y, width, height},
		Spacing = 5,
		Margin = 5,
		ui:VGroup{
			ID = 'root',

			-- Add your GUI elements here:
			ui:HGroup{
				ui:Label{
					ID = 'SearchLabel',
					Weight = 0.001,
					Text = 'Search:',
				},
				ui:HGap(5),
				ui:LineEdit{
					Weight = 5.0,
					ID='TextEntryLineEdit',
					Text = '',
					ClearButtonEnabled = true,
				},
				ui:HGap(5),
				ui:Button{
					ID = 'SearchButton',
					Weight = 0.001,
					Text = '\xF0\x9F\x94\x8D',
					Font = ui:Font{ Family = "Symbola", PixelSize = 14 },
				},
			},
		},
	})

	-- The window was closed
	function win.On.SearchWin.Close(ev)
			disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	local itm = win:GetItems()

	function win.On.SearchButton.Clicked(ev)
		print('[Search]')
		
		DoSearch()
		disp:ExitLoop()
	end
	
	function DoSearch()
	-- Search terms
		keywords = itm.TextEntryLineEdit.Text
		searchURL = "https://www.steakunderwater.com/wesuckless/search.php?keywords=" .. EncodeHTML(keywords)
		
		-- Open the webpage
		OpenURL("Search WSL", searchURL)
	end
	
	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('SearchWin', {
		Target {
			ID = 'SearchWin',
		},
		
		Hotkeys {
			Target = 'SearchWin',
			Defaults = true,
			
			CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
			CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		},
	})
	
	
	win:Show()
	disp:RunLoop()
	win:Hide()
	app:RemoveConfig('SearchWin')
	
	print("[Done]")
end

-- Run a search
Search()
