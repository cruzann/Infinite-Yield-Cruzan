if IY_LOADED and not _G.IY_DEBUG then
	-- error("Infinite Yield is already running!", 0)
	return
end

pcall(function() getgenv().IY_LOADED = true end)

local IY_RELOAD_INSTANCE_STATE = {
    sourceUrl = "https://raw.githubusercontent.com/cruzann/Infinite-Yield-Cruzan/master/InfiniteYieldCruzan.lua",
    sharedEnv = _G,
    scriptEnv = _G,
    connections = {},
    ownedInstances = {},
    gui = nil,
    scaledHolder = nil,
    quickCapture = nil,
    cleaned = false,
    cleaning = false,
    running = true,
    ready = false,
    teleportCheck = false,
    teleportQueueSource = nil,
}
pcall(function()
    if type(getgenv) == "function" then IY_RELOAD_INSTANCE_STATE.sharedEnv = getgenv() end
end)
pcall(function()
    if type(getfenv) == "function" then IY_RELOAD_INSTANCE_STATE.scriptEnv = getfenv() end
end)
IY_RELOAD_INSTANCE_STATE.sharedEnv.IY_CRUZAN_ACTIVE_STATE = IY_RELOAD_INSTANCE_STATE
IY_RELOAD_INSTANCE_STATE.TrackConnection = function(connection)
    if connection then
        IY_RELOAD_INSTANCE_STATE.connections[#IY_RELOAD_INSTANCE_STATE.connections + 1] = connection
    end
    return connection
end

if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
gethui = missing("function", gethui or get_hidden_gui)
syn = missing("table", syn)
syn_protect_gui = missing("function", syn and syn.protect_gui)
sethidden =  missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden =  missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f, ...) return f(...) end)
getgc = missing("function", getgc or get_gc_objects)
setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
replicatesignal = missing("function", replicatesignal)
getconnections = missing("function", getconnections or get_signal_cons)

Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
ExperienceService = Services.ExperienceService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
SocialService = Services.SocialService

PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
COREGUI = Services.CoreGui or PlayerGui
IYMouse = cloneref(Players.LocalPlayer:GetMouse())
PlaceId, JobId = game.PlaceId, game.JobId
xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)
isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
--[[rcdEnabled = select(2, pcall(function()
    return gethidden(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled
end)) or false]]

-- xylex & europa
local iyassets = {
	["infiniteyield/assets/bindsandplugins.png"] = "rbxassetid://5147695474",
	["infiniteyield/assets/close.png"] = "rbxassetid://5054663650",
	["infiniteyield/assets/editaliases.png"] = "rbxassetid://5147488658",
	["infiniteyield/assets/editwaypoints.png"] = "rbxassetid://5147488592",
	["infiniteyield/assets/imgstudiopluginlogo.png"] = "rbxassetid://4113050383",
	["infiniteyield/assets/logo.png"] = "rbxassetid://1352543873",
	["infiniteyield/assets/minimize.png"] = "rbxassetid://2406617031",
	["infiniteyield/assets/pin.png"] = "rbxassetid://6234691350",
	["infiniteyield/assets/reference.png"] = "rbxassetid://3523243755",
	["infiniteyield/assets/settings.png"] = "rbxassetid://1204397029",
	["infiniteyield/assets/scrollbar.png"] = "rbxassetid://75024581433929"
}

local function getcustomasset(asset)
	if waxgetcustomasset then
		local success, result = pcall(function()
			return waxgetcustomasset(asset)
		end)
		if success and result ~= nil and result ~= "" then
			return result
		end
	end
	return iyassets[asset]
end

if makefolder and isfolder and writefile and isfile then
	pcall(function() -- good executor trust
		local assets = "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/"
		for _, folder in {"infiniteyield", "infiniteyield/assets"} do
			if not isfolder(folder) then
				makefolder(folder)
			end
		end
		for path in iyassets do
			if not isfile(path) and path ~= 'infiniteyield/assets/scrollbar.png' then
				writefile(path, game:HttpGet((path:gsub("infiniteyield/", assets))))
			end
		end
		-- honestly just blame your phone if the assets appear in your gallery
		if IsOnMobile then writefile("infiniteyield/assets/.nomedia", "") end
	end)
end

currentVersion = "1.6.0"

ScaledHolder = Instance.new("Frame")
Scale = Instance.new("UIScale")
Holder = Instance.new("Frame")
Title = Instance.new("TextLabel")
Dark = Instance.new("Frame")
Cmdbar = Instance.new("TextBox")
CMDsF = Instance.new("ScrollingFrame")
cmdListLayout = Instance.new("UIListLayout")
SettingsButton = Instance.new("ImageButton")
Settings = Instance.new("Frame")
StayOpen = Instance.new("TextButton")
StayOpenButton = StayOpen
Button = Instance.new("TextButton")
On = Instance.new("TextLabel")
Positions = Instance.new("TextLabel")
EventBind = Instance.new("TextLabel")
Plugins = Instance.new("TextLabel")
Example = Instance.new("TextLabel")
Notification = Instance.new("Frame")
Title_2 = Instance.new("TextLabel")
Text_2 = Instance.new("TextLabel")
CloseButton = Instance.new("TextButton")
CloseImage = Instance.new("ImageLabel")
PinButton = Instance.new("TextButton")
PinImage = Instance.new("ImageLabel")
Tooltip = Instance.new("Frame")
Title_3 = Instance.new("TextLabel")
Description = Instance.new("TextLabel")
IntroBackground = Instance.new("Frame")
Logo = Instance.new("ImageLabel")
Credits = Instance.new("TextBox")
KeybindsFrame = Instance.new("Frame")
Close = Instance.new("TextButton")
Add = Instance.new("TextButton")
Delete = Instance.new("TextButton")
Holder_2 = Instance.new("ScrollingFrame")
Example_2 = Instance.new("Frame")
Text_3 = Instance.new("TextLabel")
Delete_2 = Instance.new("TextButton")
KeybindEditor = Instance.new("Frame")
background_2 = Instance.new("Frame")
Dark_3 = Instance.new("Frame")
Directions = Instance.new("TextLabel")
BindTo = Instance.new("TextButton")
TriggerLabel = Instance.new("TextLabel")
BindTriggerSelect = Instance.new("TextButton")
Add_2 = Instance.new("TextButton")
Toggles = Instance.new("ScrollingFrame")
ClickTP  = Instance.new("TextLabel")
Select = Instance.new("TextButton")
ClickDelete = Instance.new("TextLabel")
Select_2 = Instance.new("TextButton")
Cmdbar_2 = Instance.new("TextBox")
Cmdbar_3 = Instance.new("TextBox")
CreateToggle = Instance.new("TextLabel")
Button_2 = Instance.new("Frame")
On_2 = Instance.new("TextButton")
shadow_2 = Instance.new("Frame")
PopupText_2 = Instance.new("TextLabel")
Exit_2 = Instance.new("TextButton")
ExitImage_2 = Instance.new("ImageLabel")
PositionsFrame = Instance.new("Frame")
Close_3 = Instance.new("TextButton")
Delete_5 = Instance.new("TextButton")
AddWaypointButton = Instance.new("TextButton")
WaypointHoverFrame = Instance.new("Frame")
WaypointHoverHeader = Instance.new("TextButton")
WaypointHoverClose = Instance.new("TextButton")
WaypointBackTPLabel = Instance.new("TextLabel")
WaypointBackTPToggle = nil
WaypointHoverButton = Instance.new("TextButton")
WaypointAddDialog = Instance.new("Frame")
WaypointAddDialogTitle = Instance.new("TextLabel")
WaypointNameInput = Instance.new("TextBox")
WaypointNameHint = Instance.new("TextLabel")
WaypointAddDone = Instance.new("TextButton")
WaypointAddCancel = Instance.new("TextButton")
WaypointClearConfirmFrame = Instance.new("Frame")
WaypointClearConfirmTitle = Instance.new("TextLabel")
WaypointClearConfirmMessage = Instance.new("TextLabel")
WaypointClearConfirmButton = Instance.new("TextButton")
WaypointClearCancelButton = Instance.new("TextButton")
Holder_4 = Instance.new("ScrollingFrame")
Example_4 = Instance.new("Frame")
Text_5 = Instance.new("TextLabel")
Delete_6 = Instance.new("TextButton")
TP = Instance.new("TextButton")
WaypointHoverRowButton = Instance.new("TextButton")
AliasesFrame = Instance.new("Frame")
Close_2 = Instance.new("TextButton")
Delete_3 = Instance.new("TextButton")
AddAliasButton = Instance.new("TextButton")
AliasAddDialog = Instance.new("Frame")
AliasAddDialogTitle = Instance.new("TextLabel")
AliasCommandInput = Instance.new("TextBox")
AliasShortcutInput = Instance.new("TextBox")
AliasAddDone = Instance.new("TextButton")
AliasAddCancel = Instance.new("TextButton")
AliasClearConfirmFrame = Instance.new("Frame")
AliasClearConfirmTitle = Instance.new("TextLabel")
AliasClearConfirmMessage = Instance.new("TextLabel")
AliasClearConfirmButton = Instance.new("TextButton")
AliasClearCancelButton = Instance.new("TextButton")
Holder_3 = Instance.new("ScrollingFrame")
Example_3 = Instance.new("Frame")
Text_4 = Instance.new("TextLabel")
Delete_4 = Instance.new("TextButton")
Aliases = Instance.new("TextLabel")
PluginsFrame = Instance.new("Frame")
Close_4 = Instance.new("TextButton")
Add_3 = Instance.new("TextButton")
Holder_5 = Instance.new("ScrollingFrame")
Example_5 = Instance.new("Frame")
Text_6 = Instance.new("TextLabel")
Delete_7 = Instance.new("TextButton")
PluginEditor = Instance.new("Frame")
background_3 = Instance.new("Frame")
Dark_2 = Instance.new("Frame")
Img = Instance.new("ImageButton")
AddPlugin = Instance.new("TextButton")
FileName = Instance.new("TextBox")
About = Instance.new("TextLabel")
Directions_2 = Instance.new("TextLabel")
shadow_3 = Instance.new("Frame")
PopupText_3 = Instance.new("TextLabel")
Exit_3 = Instance.new("TextButton")
ExitImage_3 = Instance.new("ImageLabel")
AliasHint = Instance.new("TextLabel")
PluginsHint = Instance.new("TextLabel")
PositionsHint = Instance.new("TextLabel")
ToPartFrame = Instance.new("Frame")
background_4 = Instance.new("Frame")
ChoosePart = Instance.new("TextButton")
CopyPath = Instance.new("TextButton")
Directions_3 = Instance.new("TextLabel")
Path = Instance.new("TextLabel")
shadow_4 = Instance.new("Frame")
PopupText_5 = Instance.new("TextLabel")
Exit_4 = Instance.new("TextButton")
ExitImage_5 = Instance.new("ImageLabel")
logs = Instance.new("Frame")
shadow = Instance.new("Frame")
Hide = Instance.new("TextButton")
ImageLabel = Instance.new("ImageLabel")
PopupText = Instance.new("TextLabel")
Exit = Instance.new("TextButton")
ImageLabel_2 = Instance.new("ImageLabel")
background = Instance.new("Frame")
chat = Instance.new("Frame")
Clear = Instance.new("TextButton")
SaveChatlogs = Instance.new("TextButton")
Toggle = Instance.new("TextButton")
scroll_2 = Instance.new("ScrollingFrame")
join = Instance.new("Frame")
Toggle_2 = Instance.new("TextButton")
Clear_2 = Instance.new("TextButton")
scroll_3 = Instance.new("ScrollingFrame")
listlayout = Instance.new("UIListLayout",scroll_3)
selectChat = Instance.new("TextButton")
selectJoin = Instance.new("TextButton")

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

PARENT = nil
MAX_DISPLAY_ORDER = 1.7976931348623157e308
if gethui then
    local Main = Instance.new("ScreenGui")
    IY_RELOAD_INSTANCE_STATE.gui = Main
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = gethui()
    PARENT = Main
elseif (not is_sirhurt_closure) and syn_protect_gui then
    local Main = Instance.new("ScreenGui")
    IY_RELOAD_INSTANCE_STATE.gui = Main
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    syn_protect_gui(Main)
    Main.Parent = COREGUI
    PARENT = Main
elseif COREGUI:FindFirstChild("RobloxGui") then
    PARENT = COREGUI.RobloxGui
else
    local Main = Instance.new("ScreenGui")
    IY_RELOAD_INSTANCE_STATE.gui = Main
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = COREGUI
    PARENT = Main
end

shade1 = {}
shade2 = {}
shade3 = {}
text1 = {}
text2 = {}
scroll = {}

ScaledHolder.Name = randomString()
ScaledHolder.Size = UDim2.fromScale(1, 1)
ScaledHolder.BackgroundTransparency = 1
ScaledHolder.Parent = PARENT
IY_RELOAD_INSTANCE_STATE.scaledHolder = ScaledHolder
Scale.Name = randomString()

Holder.Name = randomString()
Holder.Parent = ScaledHolder
Holder.Active = true
Holder.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(1, -250, 1, IsOnMobile and 0 or -220)
Holder.Size = UDim2.new(0, 250, 0, 220)
Holder.ZIndex = 10
table.insert(shade2,Holder)

Title.Name = "Title"
Title.Parent = Holder
Title.Active = true
Title.BackgroundColor3 = Color3.fromRGB(36,36,37)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(0, 250, 0, 20)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 18
Title.Text = "Infinite Yield FE v" .. currentVersion

do
	local emoji = ({
		["01 01"] = "🎆",
		["02 14"] = "💝",
		["03 17"] = "☘️",
		[(function(Year)
			local A = math.floor(Year/100)
			local B = math.floor((13+8*A)/25)
			local C = (15-B+A-math.floor(A/4))%30
			local D = (4+A-math.floor(A/4))%7
			local E = (19*(Year%19)+C)%30
			local F = (2*(Year%4)+4*(Year%7)+6*E+D)%7
			local G = (22+E+F)
			if E == 29 and F == 6 then
				return "04 19"
			elseif E == 28 and F == 6 then
				return "04 18"
			elseif 31 < G then
				return ("04 %02d"):format(G-31)
			end
			return ("03 %02d"):format(G)
		end)(tonumber(os.date"%Y"))] = "🥚",
		["10 31"] = "🎃",
		["12 25"] = "🎄"
	})[os.date("%m %d")]
	if emoji then
		Title.Text = ("%s %s %s"):format(emoji, Title.Text, emoji)
	end
end

Title.TextColor3 = Color3.new(1, 1, 1)
Title.ZIndex = 10
table.insert(shade1,Title)
table.insert(text1,Title)

Dark.Name = "Dark"
Dark.Parent = Holder
Dark.Active = true
Dark.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Dark.BorderSizePixel = 0
Dark.Position = UDim2.new(0, 0, 0, 45)
Dark.Size = UDim2.new(0, 250, 0, 175)
Dark.ZIndex = 9
table.insert(shade1,Dark)

Cmdbar.Name = "Cmdbar"
Cmdbar.Parent = Holder
Cmdbar.BackgroundTransparency = 1
Cmdbar.BorderSizePixel = 0
Cmdbar.Position = UDim2.new(0, 5, 0, 20)
Cmdbar.Size = UDim2.new(0, 240, 0, 25)
Cmdbar.Font = Enum.Font.SourceSans
Cmdbar.TextSize = 18
Cmdbar.TextXAlignment = Enum.TextXAlignment.Left
Cmdbar.TextColor3 = Color3.new(1, 1, 1)
Cmdbar.Text = ""
Cmdbar.ZIndex = 10
Cmdbar.PlaceholderText = "Command Bar"

CMDsF.Name = "CMDs"
CMDsF.Parent = Holder
CMDsF.BackgroundColor3 = Title.BackgroundColor3
CMDsF.BackgroundTransparency = 0
CMDsF.BorderSizePixel = 0
CMDsF.Position = UDim2.new(0, 5, 0, 45)
CMDsF.Size = UDim2.new(0, 245, 0, 175)
CMDsF.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
CMDsF.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.CanvasSize = UDim2.new(0, 0, 0, 0)
CMDsF.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.ScrollBarThickness = 8
CMDsF.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.VerticalScrollBarInset = 'Always'
CMDsF.ZIndex = 10
table.insert(shade1,CMDsF)
table.insert(scroll,CMDsF)

cmdListLayout.SortOrder = Enum.SortOrder.LayoutOrder
cmdListLayout.Parent = CMDsF

SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = Holder
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(0, 230, 0, 0)
SettingsButton.Size = UDim2.new(0, 20, 0, 20)
SettingsButton.Image = getcustomasset("infiniteyield/assets/settings.png")
SettingsButton.ZIndex = 10

ReferenceButton = Instance.new("ImageButton")
ReferenceButton.Name = "ReferenceButton"
ReferenceButton.Parent = Holder
ReferenceButton.BackgroundTransparency = 1
ReferenceButton.Position = UDim2.new(0, 212, 0, 2)
ReferenceButton.Size = UDim2.new(0, 16, 0, 16)
ReferenceButton.Image = getcustomasset("infiniteyield/assets/reference.png")
ReferenceButton.ZIndex = 10

Settings.Name = "Settings"
Settings.Parent = Holder
Settings.Active = true
Settings.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(0, 0, 0, 220)
Settings.Size = UDim2.new(0, 250, 0, 175)
Settings.ClipsDescendants = true
Settings.ZIndex = 10
table.insert(shade1,Settings)

SettingsHolder = Instance.new("ScrollingFrame")
SettingsHolder.Name = "Holder"
SettingsHolder.Parent = Settings
SettingsHolder.BackgroundTransparency = 1
SettingsHolder.BorderSizePixel = 0
SettingsHolder.Size = UDim2.new(1,0,1,0)
SettingsHolder.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
SettingsHolder.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.CanvasSize = UDim2.new(0, 0, 0, 210)
SettingsHolder.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.ScrollBarThickness = 8
SettingsHolder.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.VerticalScrollBarInset = 'Always'
SettingsHolder.ZIndex = 10
table.insert(scroll,SettingsHolder)

function makeSettingsButton(name,iconID,off)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(0,0,0,0)
	button.Size = UDim2.new(1,0,0,25)
	button.Text = ""
	button.ZIndex = 10
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Parent = button
	icon.Position = UDim2.new(0,5,0,5)
	icon.Size = UDim2.new(0,16,0,16)
	icon.BackgroundTransparency = 1
	icon.Image = iconID
	icon.ZIndex = 10
	if off then
		icon.ScaleType = Enum.ScaleType.Crop
		icon.ImageRectSize = Vector2.new(16,16)
		icon.ImageRectOffset = Vector2.new(off,0)
	end
	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Text = name
	label.Position = UDim2.new(0,28,0,0)
	label.Size = UDim2.new(1,-28,1,0)
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.ZIndex = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(shade2,button)
	table.insert(text1,label)
	return button
end

Aliases = makeSettingsButton("Edit Aliases",getcustomasset("infiniteyield/assets/editaliases.png"))
Aliases.Position = UDim2.new(0, 5, 0, 85)
Aliases.Size = UDim2.new(1, -10, 0, 25)
Aliases.Name = "Aliases"
Aliases.Parent = SettingsHolder

StayOpen.Name = "StayOpen"
StayOpen.Parent = SettingsHolder
StayOpen.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
StayOpen.BorderSizePixel = 0
StayOpen.BackgroundTransparency = 1
StayOpen.Position = UDim2.new(0, 5, 0, 5)
StayOpen.Size = UDim2.new(1, -10, 0, 20)
StayOpen.Font = Enum.Font.SourceSans
StayOpen.TextSize = 14
StayOpen.Text = "Keep Menu Open"
StayOpen.TextColor3 = Color3.new(1, 1, 1)
StayOpen.TextXAlignment = Enum.TextXAlignment.Left
StayOpen.ZIndex = 10
StayOpen.AutoButtonColor = false
table.insert(shade2,StayOpen)
table.insert(text1,StayOpen)

Button.Name = "Button"
Button.Parent = StayOpen
Button.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button.Text = ""
Button.AutoButtonColor = false
Button.BorderSizePixel = 0
Button.Position = UDim2.new(1, -20, 0, 0)
Button.Size = UDim2.new(0, 20, 0, 20)
Button.ZIndex = 10
table.insert(shade3,Button)

On.Name = "On"
On.Parent = Button
On.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On.BackgroundTransparency = 1
On.BorderSizePixel = 0
On.Position = UDim2.new(0, 2, 0, 2)
On.Size = UDim2.new(0, 16, 0, 16)
On.Font = Enum.Font.SourceSans
On.FontSize = Enum.FontSize.Size14
On.Text = ""
On.TextColor3 = Color3.new(0, 0, 0)
On.ZIndex = 10

Positions = makeSettingsButton("Edit/Goto Waypoints",getcustomasset("infiniteyield/assets/editwaypoints.png"))
Positions.Position = UDim2.new(0, 5, 0, 115)
Positions.Size = UDim2.new(1, -10, 0, 25)
Positions.Name = "Waypoints"
Positions.Parent = SettingsHolder

EventBind = makeSettingsButton("Edit Event Binds",getcustomasset("infiniteyield/assets/bindsandplugins.png"),759)
EventBind.Position = UDim2.new(0, 5, 0, 175)
EventBind.Size = UDim2.new(1, -10, 0, 25)
EventBind.Name = "EventBinds"
EventBind.Parent = SettingsHolder

Plugins = makeSettingsButton("Manage Plugins",getcustomasset("infiniteyield/assets/bindsandplugins.png"),743)
Plugins.Position = UDim2.new(0, 5, 0, 145)
Plugins.Size = UDim2.new(1, -10, 0, 25)
Plugins.Name = "Plugins"
Plugins.Parent = SettingsHolder

-- Configurable delay before the main interface auto-hides.
AutoHideDelayLabel = Instance.new("TextLabel")
AutoHideDelayLabel.Name = "AutoHideDelayLabel"
AutoHideDelayLabel.Parent = SettingsHolder
AutoHideDelayLabel.BackgroundTransparency = 1
AutoHideDelayLabel.Position = UDim2.new(0, 5, 0, 30)
AutoHideDelayLabel.Size = UDim2.new(1, -10, 0, 20)
AutoHideDelayLabel.Font = Enum.Font.SourceSans
AutoHideDelayLabel.TextSize = 14
AutoHideDelayLabel.Text = "Auto-hide delay (sec)"
AutoHideDelayLabel.TextColor3 = Color3.new(1, 1, 1)
AutoHideDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoHideDelayLabel.ZIndex = 10
table.insert(shade2, AutoHideDelayLabel)
table.insert(text1, AutoHideDelayLabel)

AutoHideDelayBox = Instance.new("TextBox")
AutoHideDelayBox.Name = "AutoHideDelayBox"
AutoHideDelayBox.Parent = AutoHideDelayLabel
AutoHideDelayBox.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
AutoHideDelayBox.BorderSizePixel = 0
AutoHideDelayBox.Position = UDim2.new(1, -20, 0, 0)
AutoHideDelayBox.Size = UDim2.new(0, 20, 0, 20)
AutoHideDelayBox.Font = Enum.Font.SourceSansBold
AutoHideDelayBox.TextSize = 12
AutoHideDelayBox.Text = "1.5"
AutoHideDelayBox.TextColor3 = Color3.new(1, 1, 1)
AutoHideDelayBox.ClearTextOnFocus = false
AutoHideDelayBox.TextXAlignment = Enum.TextXAlignment.Center
AutoHideDelayBox.ZIndex = 10
table.insert(shade3, AutoHideDelayBox)
table.insert(text1, AutoHideDelayBox)

FavCmdsButton = makeSettingsButton("Manage Fav cmds", getcustomasset("infiniteyield/assets/editaliases.png"))
FavCmdsButton.Position = UDim2.new(0, 5, 0, 55)
FavCmdsButton.Size = UDim2.new(1, -10, 0, 25)
FavCmdsButton.Name = "FavoriteCommands"
FavCmdsButton.Parent = SettingsHolder

Example.Name = "Example"
Example.Parent = Holder
Example.BackgroundTransparency = 1
Example.BorderSizePixel = 0
Example.Size = UDim2.new(0, 190, 0, 20)
Example.Visible = false
Example.Font = Enum.Font.SourceSans
Example.TextSize = 18
Example.Text = "Example"
Example.TextColor3 = Color3.new(1, 1, 1)
Example.TextXAlignment = Enum.TextXAlignment.Left
Example.ZIndex = 10
table.insert(text1,Example)

Notification.Name = randomString()
Notification.Parent = ScaledHolder
Notification.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Notification.BorderSizePixel = 0
Notification.Position = UDim2.new(1, -500, 1, 20)
Notification.Size = UDim2.new(0, 250, 0, 100)
Notification.ZIndex = 10
table.insert(shade1,Notification)

Title_2.Name = "Title"
Title_2.Parent = Notification
Title_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_2.BorderSizePixel = 0
Title_2.Size = UDim2.new(0, 250, 0, 20)
Title_2.Font = Enum.Font.SourceSans
Title_2.TextSize = 14
Title_2.Text = "Notification Title"
Title_2.TextColor3 = Color3.new(1, 1, 1)
Title_2.ZIndex = 10
table.insert(shade2,Title_2)
table.insert(text1,Title_2)

Text_2.Name = "Text"
Text_2.Parent = Notification
Text_2.BackgroundTransparency = 1
Text_2.BorderSizePixel = 0
Text_2.Position = UDim2.new(0, 5, 0, 25)
Text_2.Size = UDim2.new(0, 240, 0, 75)
Text_2.Font = Enum.Font.SourceSans
Text_2.TextSize = 16
Text_2.Text = "Notification Text"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextWrapped = true
Text_2.ZIndex = 10
table.insert(text1,Text_2)

CloseButton.Name = "CloseButton"
CloseButton.Parent = Notification
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = ""
CloseButton.ZIndex = 10

CloseImage.Parent = CloseButton
CloseImage.BackgroundColor3 = Color3.new(1, 1, 1)
CloseImage.BackgroundTransparency = 1
CloseImage.Position = UDim2.new(0, 5, 0, 5)
CloseImage.Size = UDim2.new(0, 10, 0, 10)
CloseImage.Image = getcustomasset("infiniteyield/assets/close.png")
CloseImage.ZIndex = 10

PinButton.Name = "PinButton"
PinButton.Parent = Notification
PinButton.BackgroundTransparency = 1
PinButton.Size = UDim2.new(0, 20, 0, 20)
PinButton.ZIndex = 10
PinButton.Text = ""

PinImage.Parent = PinButton
PinImage.BackgroundColor3 = Color3.new(1, 1, 1)
PinImage.BackgroundTransparency = 1
PinImage.Position = UDim2.new(0, 3, 0, 3)
PinImage.Size = UDim2.new(0, 14, 0, 14)
PinImage.ZIndex = 10
PinImage.Image = getcustomasset("infiniteyield/assets/pin.png")

Tooltip.Name = randomString()
Tooltip.Parent = ScaledHolder
Tooltip.Active = true
Tooltip.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.Size = UDim2.new(0, 200, 0, 96)
Tooltip.Visible = false
Tooltip.ZIndex = 10
table.insert(shade1,Tooltip)

Title_3.Name = "Title"
Title_3.Parent = Tooltip
Title_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_3.BackgroundTransparency = 0.1
Title_3.BorderSizePixel = 0
Title_3.Size = UDim2.new(0, 200, 0, 20)
Title_3.Font = Enum.Font.SourceSans
Title_3.TextSize = 14
Title_3.Text = ""
Title_3.TextColor3 = Color3.new(1, 1, 1)
Title_3.TextTransparency = 0.1
Title_3.ZIndex = 10
table.insert(shade2,Title_3)
table.insert(text1,Title_3)

Description.Name = "Description"
Description.Parent = Tooltip
Description.BackgroundTransparency = 1
Description.BorderSizePixel = 0
Description.Size = UDim2.new(0,180,0,72)
Description.Position = UDim2.new(0,10,0,18)
Description.Font = Enum.Font.SourceSans
Description.TextSize = 16
Description.Text = ""
Description.TextColor3 = Color3.new(1, 1, 1)
Description.TextTransparency = 0.1
Description.TextWrapped = true
Description.ZIndex = 10
table.insert(text1,Description)

IntroBackground.Name = "IntroBackground"
IntroBackground.Parent = Holder
IntroBackground.Active = true
IntroBackground.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
IntroBackground.BorderSizePixel = 0
IntroBackground.Position = UDim2.new(0, 0, 0, 45)
IntroBackground.Size = UDim2.new(0, 250, 0, 175)
IntroBackground.ZIndex = 10

Logo.Name = "Logo"
Logo.Parent = Holder
Logo.BackgroundTransparency = 1
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0, 125, 0, 127)
Logo.Size = UDim2.new(0, 10, 0, 10)
Logo.Image = getcustomasset("infiniteyield/assets/logo.png")
Logo.ImageTransparency = 0
Logo.ZIndex = 10

Credits.Name = "Credits"
Credits.Parent = Holder
Credits.BackgroundTransparency = 1
Credits.BorderSizePixel = 0
Credits.Position = UDim2.new(0, 0, 0.9, 30)
Credits.Size = UDim2.new(0, 250, 0, 20)
Credits.Font = Enum.Font.SourceSansLight
Credits.FontSize = Enum.FontSize.Size14
Credits.Text = "Edge // Zwolf // Moon // Toon // Peyton // ATP"
Credits.TextColor3 = Color3.new(1, 1, 1)
Credits.ZIndex = 10

KeybindsFrame.Name = "KeybindsFrame"
KeybindsFrame.Parent = Settings
KeybindsFrame.Active = true
KeybindsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
KeybindsFrame.BorderSizePixel = 0
KeybindsFrame.Position = UDim2.new(0, 0, 0, 200)
KeybindsFrame.Size = UDim2.new(0, 250, 0, 200)
KeybindsFrame.ZIndex = 10
table.insert(shade1,KeybindsFrame)

Close.Name = "Close"
Close.Parent = KeybindsFrame
Close.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 205, 0, 175)
Close.Size = UDim2.new(0, 40, 0, 20)
Close.Font = Enum.Font.SourceSans
Close.TextSize = 14
Close.Text = "Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.ZIndex = 10
table.insert(shade2,Close)
table.insert(text1,Close)

Add.Name = "Add"
Add.Parent = KeybindsFrame
Add.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add.BorderSizePixel = 0
Add.Position = UDim2.new(0, 5, 0, 175)
Add.Size = UDim2.new(0, 40, 0, 20)
Add.Font = Enum.Font.SourceSans
Add.TextSize = 14
Add.Text = "Add"
Add.TextColor3 = Color3.new(1, 1, 1)
Add.ZIndex = 10
table.insert(shade2,Add)
table.insert(text1,Add)

Delete.Name = "Delete"
Delete.Parent = KeybindsFrame
Delete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete.BorderSizePixel = 0
Delete.Position = UDim2.new(0, 50, 0, 175)
Delete.Size = UDim2.new(0, 40, 0, 20)
Delete.Font = Enum.Font.SourceSans
Delete.TextSize = 14
Delete.Text = "Clear"
Delete.TextColor3 = Color3.new(1, 1, 1)
Delete.ZIndex = 10
table.insert(shade2,Delete)
table.insert(text1,Delete)

Holder_2.Name = "Holder"
Holder_2.Parent = KeybindsFrame
Holder_2.BackgroundTransparency = 1
Holder_2.BorderSizePixel = 0
Holder_2.Position = UDim2.new(0, 0, 0, 0)
Holder_2.Size = UDim2.new(0, 250, 0, 170)
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.ScrollBarThickness = 0
Holder_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.VerticalScrollBarInset = 'Always'
Holder_2.ZIndex = 10

Example_2.Name = "Example"
Example_2.Parent = KeybindsFrame
Example_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_2.BorderSizePixel = 0
Example_2.Size = UDim2.new(0, 10, 0, 20)
Example_2.Visible = false
Example_2.ZIndex = 10
table.insert(shade2,Example_2)

Text_3.Name = "Text"
Text_3.Parent = Example_2
Text_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_3.BorderSizePixel = 0
Text_3.Position = UDim2.new(0, 10, 0, 0)
Text_3.Size = UDim2.new(0, 240, 0, 20)
Text_3.Font = Enum.Font.SourceSans
Text_3.TextSize = 14
Text_3.Text = "nom"
Text_3.TextColor3 = Color3.new(1, 1, 1)
Text_3.TextXAlignment = Enum.TextXAlignment.Left
Text_3.ZIndex = 10
table.insert(shade2,Text_3)
table.insert(text1,Text_3)

Delete_2.Name = "Delete"
Delete_2.Parent = Text_3
Delete_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_2.BorderSizePixel = 0
Delete_2.Position = UDim2.new(0, 200, 0, 0)
Delete_2.Size = UDim2.new(0, 40, 0, 20)
Delete_2.Font = Enum.Font.SourceSans
Delete_2.TextSize = 14
Delete_2.Text = "Delete"
Delete_2.TextColor3 = Color3.new(0, 0, 0)
Delete_2.ZIndex = 10
table.insert(shade3,Delete_2)
table.insert(text2,Delete_2)

KeybindEditor.Name = randomString()
KeybindEditor.Parent = ScaledHolder
KeybindEditor.Active = true
KeybindEditor.BackgroundTransparency = 1
KeybindEditor.Position = UDim2.new(0.5, -180, 0, -500)
KeybindEditor.Size = UDim2.new(0, 360, 0, 20)
KeybindEditor.ZIndex = 10

background_2.Name = "background"
background_2.Parent = KeybindEditor
background_2.Active = true
background_2.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_2.BorderSizePixel = 0
background_2.Position = UDim2.new(0, 0, 0, 20)
background_2.Size = UDim2.new(0, 360, 0, 185)
background_2.ZIndex = 10
table.insert(shade1,background_2)

Dark_3.Name = "Dark"
Dark_3.Parent = background_2
Dark_3.Active = true
Dark_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_3.BorderSizePixel = 0
Dark_3.Position = UDim2.new(0, 135, 0, 0)
Dark_3.Size = UDim2.new(0, 2, 0, 185)
Dark_3.ZIndex = 10
table.insert(shade2,Dark_3)

Directions.Name = "Directions"
Directions.Parent = background_2
Directions.BackgroundTransparency = 1
Directions.BorderSizePixel = 0
Directions.Position = UDim2.new(0, 10, 0, 15)
Directions.Size = UDim2.new(0, 115, 0, 90)
Directions.ZIndex = 10
Directions.Font = Enum.Font.SourceSans
Directions.Text = "Click the button below and press a key/mouse button. Then select what you want to bind it to."
Directions.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions.TextSize = 14.000
Directions.TextWrapped = true
Directions.TextYAlignment = Enum.TextYAlignment.Top
table.insert(text1,Directions)

BindTo.Name = "BindTo"
BindTo.Parent = background_2
BindTo.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTo.BorderSizePixel = 0
BindTo.Position = UDim2.new(0, 10, 0, 95)
BindTo.Size = UDim2.new(0, 115, 0, 50)
BindTo.ZIndex = 10
BindTo.Font = Enum.Font.SourceSans
BindTo.Text = "Click to bind"
BindTo.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTo.TextSize = 16.000
table.insert(shade2,BindTo)
table.insert(text1,BindTo)

TriggerLabel.Name = "TriggerLabel"
TriggerLabel.Parent = background_2
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Position = UDim2.new(0, 10, 0, 155)
TriggerLabel.Size = UDim2.new(0, 45, 0, 20)
TriggerLabel.ZIndex = 10
TriggerLabel.Font = Enum.Font.SourceSans
TriggerLabel.Text = "Trigger:"
TriggerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TriggerLabel.TextSize = 14.000
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,TriggerLabel)

BindTriggerSelect.Name = "BindTo"
BindTriggerSelect.Parent = background_2
BindTriggerSelect.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTriggerSelect.BorderSizePixel = 0
BindTriggerSelect.Position = UDim2.new(0, 60, 0, 155)
BindTriggerSelect.Size = UDim2.new(0, 65, 0, 20)
BindTriggerSelect.ZIndex = 10
BindTriggerSelect.Font = Enum.Font.SourceSans
BindTriggerSelect.Text = "KeyDown"
BindTriggerSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTriggerSelect.TextSize = 16.000
table.insert(shade2,BindTriggerSelect)
table.insert(text1,BindTriggerSelect)

Add_2.Name = "Add"
Add_2.Parent = background_2
Add_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_2.BorderSizePixel = 0
Add_2.Position = UDim2.new(0, 310, 0, 35)
Add_2.Size = UDim2.new(0, 40, 0, 20)
Add_2.ZIndex = 10
Add_2.Font = Enum.Font.SourceSans
Add_2.Text = "Add"
Add_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Add_2.TextSize = 14.000
table.insert(shade2,Add_2)
table.insert(text1,Add_2)

Toggles.Name = "Toggles"
Toggles.Parent = background_2
Toggles.BackgroundTransparency = 1
Toggles.BorderSizePixel = 0
Toggles.Position = UDim2.new(0, 150, 0, 125)
Toggles.Size = UDim2.new(0, 200, 0, 50)
Toggles.ZIndex = 10
Toggles.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.CanvasSize = UDim2.new(0, 0, 0, 50)
Toggles.ScrollBarThickness = 8
Toggles.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.VerticalScrollBarInset = Enum.ScrollBarInset.Always
table.insert(scroll,Toggles)

ClickTP.Name = "Click TP (Hold Key & Click)"
ClickTP.Parent = Toggles
ClickTP.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickTP.BorderSizePixel = 0
ClickTP.Size = UDim2.new(0, 200, 0, 20)
ClickTP.ZIndex = 10
ClickTP.Font = Enum.Font.SourceSans
ClickTP.Text = "    Click TP (Hold Key & Click)"
ClickTP.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickTP.TextSize = 14.000
ClickTP.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickTP)
table.insert(text1,ClickTP)

Select.Name = "Select"
Select.Parent = ClickTP
Select.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select.BorderSizePixel = 0
Select.Position = UDim2.new(0, 160, 0, 0)
Select.Size = UDim2.new(0, 40, 0, 20)
Select.ZIndex = 10
Select.Font = Enum.Font.SourceSans
Select.Text = "Add"
Select.TextColor3 = Color3.fromRGB(0, 0, 0)
Select.TextSize = 14.000
table.insert(shade3,Select)
table.insert(text2,Select)

ClickDelete.Name = "Click Delete (Hold Key & Click)"
ClickDelete.Parent = Toggles
ClickDelete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickDelete.BorderSizePixel = 0
ClickDelete.Position = UDim2.new(0, 0, 0, 25)
ClickDelete.Size = UDim2.new(0, 200, 0, 20)
ClickDelete.ZIndex = 10
ClickDelete.Font = Enum.Font.SourceSans
ClickDelete.Text = "    Click Delete (Hold Key & Click)"
ClickDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelete.TextSize = 14.000
ClickDelete.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickDelete)
table.insert(text1,ClickDelete)

Select_2.Name = "Select"
Select_2.Parent = ClickDelete
Select_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select_2.BorderSizePixel = 0
Select_2.Position = UDim2.new(0, 160, 0, 0)
Select_2.Size = UDim2.new(0, 40, 0, 20)
Select_2.ZIndex = 10
Select_2.Font = Enum.Font.SourceSans
Select_2.Text = "Add"
Select_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Select_2.TextSize = 14.000
table.insert(shade3,Select_2)
table.insert(text2,Select_2)

Cmdbar_2.Name = "Cmdbar_2"
Cmdbar_2.Parent = background_2
Cmdbar_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_2.BorderSizePixel = 0
Cmdbar_2.Position = UDim2.new(0, 150, 0, 35)
Cmdbar_2.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_2.ZIndex = 10
Cmdbar_2.Font = Enum.Font.SourceSans
Cmdbar_2.PlaceholderText = "Command"
Cmdbar_2.Text = ""
Cmdbar_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_2.TextSize = 14.000
Cmdbar_2.TextXAlignment = Enum.TextXAlignment.Left

Cmdbar_3.Name = "Cmdbar_3"
Cmdbar_3.Parent = background_2
Cmdbar_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_3.BorderSizePixel = 0
Cmdbar_3.Position = UDim2.new(0, 150, 0, 60)
Cmdbar_3.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_3.ZIndex = 10
Cmdbar_3.Font = Enum.Font.SourceSans
Cmdbar_3.PlaceholderText = "Command 2"
Cmdbar_3.Text = ""
Cmdbar_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_3.TextSize = 14.000
Cmdbar_3.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle.Name = "CreateToggle"
CreateToggle.Parent = background_2
CreateToggle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CreateToggle.BackgroundTransparency = 1
CreateToggle.BorderSizePixel = 0
CreateToggle.Position = UDim2.new(0, 152, 0, 10)
CreateToggle.Size = UDim2.new(0, 198, 0, 20)
CreateToggle.ZIndex = 10
CreateToggle.Font = Enum.Font.SourceSans
CreateToggle.Text = "Create Toggle"
CreateToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CreateToggle.TextSize = 14.000
CreateToggle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,CreateToggle)

Button_2.Name = "Button"
Button_2.Parent = CreateToggle
Button_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(1, -20, 0, 0)
Button_2.Size = UDim2.new(0, 20, 0, 20)
Button_2.ZIndex = 10
table.insert(shade3,Button_2)

On_2.Name = "On"
On_2.Parent = Button_2
On_2.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On_2.BackgroundTransparency = 1
On_2.BorderSizePixel = 0
On_2.Position = UDim2.new(0, 2, 0, 2)
On_2.Size = UDim2.new(0, 16, 0, 16)
On_2.ZIndex = 10
On_2.Font = Enum.Font.SourceSans
On_2.Text = ""
On_2.TextColor3 = Color3.fromRGB(0, 0, 0)
On_2.TextSize = 14.000

shadow_2.Name = "shadow"
shadow_2.Parent = KeybindEditor
shadow_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_2.BorderSizePixel = 0
shadow_2.Size = UDim2.new(0, 360, 0, 20)
shadow_2.ZIndex = 10
table.insert(shade2,shadow_2)

PopupText_2.Name = "PopupText_2"
PopupText_2.Parent = shadow_2
PopupText_2.BackgroundTransparency = 1
PopupText_2.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText_2.ZIndex = 10
PopupText_2.Font = Enum.Font.SourceSans
PopupText_2.Text = "Set Keybinds"
PopupText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupText_2.TextSize = 14.000
PopupText_2.TextWrapped = true
table.insert(text1,PopupText_2)

Exit_2.Name = "Exit_2"
Exit_2.Parent = shadow_2
Exit_2.BackgroundTransparency = 1
Exit_2.Position = UDim2.new(1, -20, 0, 0)
Exit_2.Size = UDim2.new(0, 20, 0, 20)
Exit_2.ZIndex = 10
Exit_2.Text = ""

ExitImage_2.Parent = Exit_2
ExitImage_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ExitImage_2.BackgroundTransparency = 1
ExitImage_2.Position = UDim2.new(0, 5, 0, 5)
ExitImage_2.Size = UDim2.new(0, 10, 0, 10)
ExitImage_2.ZIndex = 10
ExitImage_2.Image = getcustomasset("infiniteyield/assets/close.png")

PositionsFrame.Name = "PositionsFrame"
PositionsFrame.Parent = Settings
PositionsFrame.Active = true
PositionsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PositionsFrame.BorderSizePixel = 0
PositionsFrame.Size = UDim2.new(0, 250, 0, 200)
PositionsFrame.Position = UDim2.new(0, 0, 0, 200)
PositionsFrame.ZIndex = 10
table.insert(shade1,PositionsFrame)

Close_3.Name = "Close"
Close_3.Parent = PositionsFrame
Close_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_3.BorderSizePixel = 0
Close_3.Position = UDim2.new(0, 205, 0, 175)
Close_3.Size = UDim2.new(0, 40, 0, 20)
Close_3.Font = Enum.Font.SourceSans
Close_3.TextSize = 14
Close_3.Text = "Close"
Close_3.TextColor3 = Color3.new(1, 1, 1)
Close_3.ZIndex = 10
table.insert(shade2,Close_3)
table.insert(text1,Close_3)

Delete_5.Name = "Delete"
Delete_5.Parent = PositionsFrame
Delete_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_5.BorderSizePixel = 0
Delete_5.Position = UDim2.new(0, 5, 0, 175)
Delete_5.Size = UDim2.new(0, 40, 0, 20)
Delete_5.Font = Enum.Font.SourceSans
Delete_5.TextSize = 14
Delete_5.Text = "Clear"
Delete_5.TextColor3 = Color3.new(1, 1, 1)
Delete_5.ZIndex = 10
table.insert(shade2,Delete_5)
table.insert(text1,Delete_5)

-- Add button beside Clear for creating waypoints through the UI.
AddWaypointButton.Name = "AddWaypointButton"
AddWaypointButton.Parent = PositionsFrame
AddWaypointButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AddWaypointButton.BorderSizePixel = 0
AddWaypointButton.Position = UDim2.new(0, 50, 0, 175)
AddWaypointButton.Size = UDim2.new(0, 40, 0, 20)
AddWaypointButton.Font = Enum.Font.SourceSans
AddWaypointButton.TextSize = 14
AddWaypointButton.Text = "Add"
AddWaypointButton.TextColor3 = Color3.new(1, 1, 1)
AddWaypointButton.ZIndex = 12
table.insert(shade2,AddWaypointButton)
table.insert(text1,AddWaypointButton)

-- Shared BackTP option in Edit/Goto Waypoints, placed immediately left of Close.
WaypointBackTPLabel.Name = "BackTPLabel"
WaypointBackTPLabel.Parent = PositionsFrame
WaypointBackTPLabel.BackgroundTransparency = 1
WaypointBackTPLabel.BorderSizePixel = 0
WaypointBackTPLabel.Position = UDim2.new(0, 126, 0, 175)
WaypointBackTPLabel.Size = UDim2.new(0, 44, 0, 20)
WaypointBackTPLabel.Font = Enum.Font.SourceSans
WaypointBackTPLabel.TextSize = 14
WaypointBackTPLabel.Text = "BackTP"
WaypointBackTPLabel.TextColor3 = Color3.new(1, 1, 1)
WaypointBackTPLabel.TextXAlignment = Enum.TextXAlignment.Right
WaypointBackTPLabel.TextYAlignment = Enum.TextYAlignment.Center
WaypointBackTPLabel.ZIndex = 12
table.insert(text1, WaypointBackTPLabel)

WaypointBackTPToggle = Button:Clone()
WaypointBackTPToggle.Name = "BackTPToggle"
WaypointBackTPToggle.Parent = PositionsFrame
WaypointBackTPToggle.BackgroundColor3 = currentShade3 or Color3.fromRGB(78, 78, 79)
WaypointBackTPToggle.BorderSizePixel = 0
WaypointBackTPToggle.AutoButtonColor = false
WaypointBackTPToggle.Position = UDim2.new(0, 174, 0, 175)
WaypointBackTPToggle.Size = UDim2.new(0, 20, 0, 20)
WaypointBackTPToggle.ZIndex = 12
local waypointBackTPCheckmark = WaypointBackTPToggle:FindFirstChild("On")
if waypointBackTPCheckmark then
    waypointBackTPCheckmark.Name = "Checkmark"
    waypointBackTPCheckmark.ZIndex = 13
    waypointBackTPCheckmark.TextSize = 13
    waypointBackTPCheckmark.TextColor3 = Color3.new(1, 1, 1)
end
table.insert(shade3, WaypointBackTPToggle)

Holder_4.Name = "Holder"
Holder_4.Parent = PositionsFrame
Holder_4.BackgroundTransparency = 1
Holder_4.BorderSizePixel = 0
Holder_4.Position = UDim2.new(0, 0, 0, 0)
Holder_4.Selectable = false
Holder_4.Size = UDim2.new(0, 250, 0, 170)
Holder_4.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_4.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_4.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.ScrollBarThickness = 0
Holder_4.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.VerticalScrollBarInset = 'Always'
Holder_4.ZIndex = 10

Example_4.Name = "Example"
Example_4.Parent = PositionsFrame
Example_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_4.BorderSizePixel = 0
Example_4.Size = UDim2.new(0, 10, 0, 20)
Example_4.Visible = false
Example_4.Position = UDim2.new(0, 0, 0, -5)
Example_4.ZIndex = 10
table.insert(shade2,Example_4)

Text_5.Name = "Text"
Text_5.Parent = Example_4
Text_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_5.BorderSizePixel = 0
Text_5.Position = UDim2.new(0, 10, 0, 0)
Text_5.Size = UDim2.new(0, 240, 0, 20)
Text_5.Font = Enum.Font.SourceSans
Text_5.TextSize = 14
Text_5.Text = "Position"
Text_5.TextColor3 = Color3.new(1, 1, 1)
Text_5.TextXAlignment = Enum.TextXAlignment.Left
Text_5.ZIndex = 10
table.insert(shade2,Text_5)
table.insert(text1,Text_5)

Delete_6.Name = "Delete"
Delete_6.Parent = Text_5
Delete_6.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_6.BorderSizePixel = 0
Delete_6.Position = UDim2.new(0, 200, 0, 0)
Delete_6.Size = UDim2.new(0, 40, 0, 20)
Delete_6.Font = Enum.Font.SourceSans
Delete_6.TextSize = 14
Delete_6.Text = "Delete"
Delete_6.TextColor3 = Color3.new(0, 0, 0)
Delete_6.ZIndex = 10
table.insert(shade3,Delete_6)
table.insert(text2,Delete_6)

TP.Name = "TP"
TP.Parent = Text_5
TP.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
TP.BorderSizePixel = 0
TP.Position = UDim2.new(0, 155, 0, 0)
TP.Size = UDim2.new(0, 40, 0, 20)
TP.Font = Enum.Font.SourceSans
TP.TextSize = 14
TP.Text = "Goto"
TP.TextColor3 = Color3.new(0, 0, 0)
TP.ZIndex = 10
table.insert(shade3,TP)
table.insert(text2,TP)

WaypointHoverRowButton.Name = "Hover"
WaypointHoverRowButton.Parent = Text_5
WaypointHoverRowButton.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
WaypointHoverRowButton.BorderSizePixel = 0
WaypointHoverRowButton.Position = UDim2.new(0, 110, 0, 0)
WaypointHoverRowButton.Size = UDim2.new(0, 40, 0, 20)
WaypointHoverRowButton.Font = Enum.Font.SourceSans
WaypointHoverRowButton.TextSize = 14
WaypointHoverRowButton.Text = "Hover"
WaypointHoverRowButton.TextColor3 = Color3.new(0, 0, 0)
WaypointHoverRowButton.ZIndex = 10
table.insert(shade3, WaypointHoverRowButton)
table.insert(text2, WaypointHoverRowButton)

AliasesFrame.Name = "AliasesFrame"
AliasesFrame.Parent = Settings
AliasesFrame.Active = true
AliasesFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
AliasesFrame.BorderSizePixel = 0
AliasesFrame.Position = UDim2.new(0, 0, 0, 200)
AliasesFrame.Size = UDim2.new(0, 250, 0, 200)
AliasesFrame.ZIndex = 10
table.insert(shade1,AliasesFrame)

Close_2.Name = "Close"
Close_2.Parent = AliasesFrame
Close_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_2.BorderSizePixel = 0
Close_2.Position = UDim2.new(0, 205, 0, 175)
Close_2.Size = UDim2.new(0, 40, 0, 20)
Close_2.Font = Enum.Font.SourceSans
Close_2.TextSize = 14
Close_2.Text = "Close"
Close_2.TextColor3 = Color3.new(1, 1, 1)
Close_2.ZIndex = 10
table.insert(shade2,Close_2)
table.insert(text1,Close_2)

Delete_3.Name = "Delete"
Delete_3.Parent = AliasesFrame
Delete_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_3.BorderSizePixel = 0
Delete_3.Position = UDim2.new(0, 5, 0, 175)
Delete_3.Size = UDim2.new(0, 40, 0, 20)
Delete_3.Font = Enum.Font.SourceSans
Delete_3.TextSize = 14
Delete_3.Text = "Clear"
Delete_3.TextColor3 = Color3.new(1, 1, 1)
Delete_3.ZIndex = 10
table.insert(shade2,Delete_3)
table.insert(text1,Delete_3)

-- Add button beside Clear for creating aliases through the UI.
AddAliasButton.Name = "AddAliasButton"
AddAliasButton.Parent = AliasesFrame
AddAliasButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AddAliasButton.BorderSizePixel = 0
AddAliasButton.Position = UDim2.new(0, 50, 0, 175)
AddAliasButton.Size = UDim2.new(0, 40, 0, 20)
AddAliasButton.Font = Enum.Font.SourceSans
AddAliasButton.TextSize = 14
AddAliasButton.Text = "Add"
AddAliasButton.TextColor3 = Color3.new(1, 1, 1)
AddAliasButton.ZIndex = 12
table.insert(shade2,AddAliasButton)
table.insert(text1,AddAliasButton)

-- Alias creation is a separate page inside Settings, matching the Fav cmds picker navigation.
AliasAddDialog.Name = "AliasAddDialog"
AliasAddDialog.Parent = Settings
AliasAddDialog.Active = true
AliasAddDialog.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
AliasAddDialog.BorderSizePixel = 0
AliasAddDialog.Position = UDim2.new(0, 0, 0, 200)
AliasAddDialog.Size = UDim2.new(0, 250, 0, 200)
AliasAddDialog.Visible = false
AliasAddDialog.ZIndex = 30
table.insert(shade1,AliasAddDialog)

AliasAddDialogTitle.Name = "Title"
AliasAddDialogTitle.Parent = AliasAddDialog
AliasAddDialogTitle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasAddDialogTitle.BorderSizePixel = 0
AliasAddDialogTitle.Position = UDim2.new(0, 0, 0, 0)
AliasAddDialogTitle.Size = UDim2.new(1, 0, 0, 22)
AliasAddDialogTitle.Font = Enum.Font.SourceSans
AliasAddDialogTitle.TextSize = 14
AliasAddDialogTitle.Text = "Add Alias"
AliasAddDialogTitle.TextColor3 = Color3.new(1, 1, 1)
AliasAddDialogTitle.ZIndex = 31
table.insert(shade2,AliasAddDialogTitle)
table.insert(text1,AliasAddDialogTitle)

AliasCommandInput.Name = "CommandInput"
AliasCommandInput.Parent = AliasAddDialog
AliasCommandInput.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasCommandInput.BorderSizePixel = 0
AliasCommandInput.ClearTextOnFocus = false
AliasCommandInput.Position = UDim2.new(0, 8, 0, 40)
AliasCommandInput.Size = UDim2.new(1, -16, 0, 24)
AliasCommandInput.Font = Enum.Font.SourceSans
AliasCommandInput.TextSize = 14
AliasCommandInput.Text = ""
AliasCommandInput.PlaceholderText = "Command name (e.g. fly)"
AliasCommandInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
AliasCommandInput.TextColor3 = Color3.new(1, 1, 1)
AliasCommandInput.TextXAlignment = Enum.TextXAlignment.Left
AliasCommandInput.ZIndex = 31
table.insert(shade2,AliasCommandInput)
table.insert(text1,AliasCommandInput)

AliasShortcutInput.Name = "ShortcutInput"
AliasShortcutInput.Parent = AliasAddDialog
AliasShortcutInput.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasShortcutInput.BorderSizePixel = 0
AliasShortcutInput.ClearTextOnFocus = false
AliasShortcutInput.Position = UDim2.new(0, 8, 0, 72)
AliasShortcutInput.Size = UDim2.new(1, -16, 0, 24)
AliasShortcutInput.Font = Enum.Font.SourceSans
AliasShortcutInput.TextSize = 14
AliasShortcutInput.Text = ""
AliasShortcutInput.PlaceholderText = "Shortcut / alias"
AliasShortcutInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
AliasShortcutInput.TextColor3 = Color3.new(1, 1, 1)
AliasShortcutInput.TextXAlignment = Enum.TextXAlignment.Left
AliasShortcutInput.ZIndex = 31
table.insert(shade2,AliasShortcutInput)
table.insert(text1,AliasShortcutInput)

AliasAddDone.Name = "Done"
AliasAddDone.Parent = AliasAddDialog
AliasAddDone.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasAddDone.BorderSizePixel = 0
AliasAddDone.Position = UDim2.new(0, 25, 0, 175)
AliasAddDone.Size = UDim2.new(0, 90, 0, 20)
AliasAddDone.Font = Enum.Font.SourceSans
AliasAddDone.TextSize = 14
AliasAddDone.Text = "Done"
AliasAddDone.TextColor3 = Color3.new(1, 1, 1)
AliasAddDone.ZIndex = 32
table.insert(shade2,AliasAddDone)
table.insert(text1,AliasAddDone)

AliasAddCancel.Name = "Cancel"
AliasAddCancel.Parent = AliasAddDialog
AliasAddCancel.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasAddCancel.BorderSizePixel = 0
AliasAddCancel.Position = UDim2.new(0, 135, 0, 175)
AliasAddCancel.Size = UDim2.new(0, 90, 0, 20)
AliasAddCancel.Font = Enum.Font.SourceSans
AliasAddCancel.TextSize = 14
AliasAddCancel.Text = "Cancel"
AliasAddCancel.TextColor3 = Color3.new(1, 1, 1)
AliasAddCancel.ZIndex = 32
table.insert(shade2,AliasAddCancel)
table.insert(text1,AliasAddCancel)

-- Dedicated confirmation page: aliases are not cleared until Confirm is pressed.
AliasClearConfirmFrame.Name = "AliasClearConfirmFrame"
AliasClearConfirmFrame.Parent = Settings
AliasClearConfirmFrame.Active = true
AliasClearConfirmFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
AliasClearConfirmFrame.BorderSizePixel = 0
AliasClearConfirmFrame.Position = UDim2.new(0, 0, 0, 200)
AliasClearConfirmFrame.Size = UDim2.new(0, 250, 0, 200)
AliasClearConfirmFrame.Visible = false
AliasClearConfirmFrame.ZIndex = 30
table.insert(shade1, AliasClearConfirmFrame)

AliasClearConfirmTitle.Name = "Title"
AliasClearConfirmTitle.Parent = AliasClearConfirmFrame
AliasClearConfirmTitle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasClearConfirmTitle.BorderSizePixel = 0
AliasClearConfirmTitle.Position = UDim2.new(0, 0, 0, 0)
AliasClearConfirmTitle.Size = UDim2.new(1, 0, 0, 22)
AliasClearConfirmTitle.Font = Enum.Font.SourceSans
AliasClearConfirmTitle.TextSize = 14
AliasClearConfirmTitle.Text = "Clear all aliases?"
AliasClearConfirmTitle.TextColor3 = Color3.new(1, 1, 1)
AliasClearConfirmTitle.ZIndex = 31
table.insert(shade2, AliasClearConfirmTitle)
table.insert(text1, AliasClearConfirmTitle)

AliasClearConfirmMessage.Name = "Message"
AliasClearConfirmMessage.Parent = AliasClearConfirmFrame
AliasClearConfirmMessage.BackgroundTransparency = 1
AliasClearConfirmMessage.BorderSizePixel = 0
AliasClearConfirmMessage.Position = UDim2.new(0, 10, 0, 48)
AliasClearConfirmMessage.Size = UDim2.new(1, -20, 0, 65)
AliasClearConfirmMessage.Font = Enum.Font.SourceSans
AliasClearConfirmMessage.TextSize = 14
AliasClearConfirmMessage.Text = "This will remove every saved alias.\nDo you want to continue?"
AliasClearConfirmMessage.TextColor3 = Color3.new(1, 1, 1)
AliasClearConfirmMessage.TextWrapped = true
AliasClearConfirmMessage.TextXAlignment = Enum.TextXAlignment.Center
AliasClearConfirmMessage.TextYAlignment = Enum.TextYAlignment.Center
AliasClearConfirmMessage.ZIndex = 31
table.insert(text1, AliasClearConfirmMessage)

AliasClearConfirmButton.Name = "Confirm"
AliasClearConfirmButton.Parent = AliasClearConfirmFrame
AliasClearConfirmButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasClearConfirmButton.BorderSizePixel = 0
AliasClearConfirmButton.Position = UDim2.new(0, 25, 0, 175)
AliasClearConfirmButton.Size = UDim2.new(0, 90, 0, 20)
AliasClearConfirmButton.Font = Enum.Font.SourceSans
AliasClearConfirmButton.TextSize = 14
AliasClearConfirmButton.Text = "Confirm"
AliasClearConfirmButton.TextColor3 = Color3.new(1, 1, 1)
AliasClearConfirmButton.ZIndex = 32
table.insert(shade2, AliasClearConfirmButton)
table.insert(text1, AliasClearConfirmButton)

AliasClearCancelButton.Name = "Cancel"
AliasClearCancelButton.Parent = AliasClearConfirmFrame
AliasClearCancelButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AliasClearCancelButton.BorderSizePixel = 0
AliasClearCancelButton.Position = UDim2.new(0, 135, 0, 175)
AliasClearCancelButton.Size = UDim2.new(0, 90, 0, 20)
AliasClearCancelButton.Font = Enum.Font.SourceSans
AliasClearCancelButton.TextSize = 14
AliasClearCancelButton.Text = "Cancel"
AliasClearCancelButton.TextColor3 = Color3.new(1, 1, 1)
AliasClearCancelButton.ZIndex = 32
table.insert(shade2, AliasClearCancelButton)
table.insert(text1, AliasClearCancelButton)

Holder_3.Name = "Holder"
Holder_3.Parent = AliasesFrame
Holder_3.BackgroundTransparency = 1
Holder_3.BorderSizePixel = 0
Holder_3.Position = UDim2.new(0, 0, 0, 0)
Holder_3.Size = UDim2.new(0, 250, 0, 170)
Holder_3.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_3.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.ScrollBarThickness = 0
Holder_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.VerticalScrollBarInset = 'Always'
Holder_3.ZIndex = 10

Example_3.Name = "Example"
Example_3.Parent = AliasesFrame
Example_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_3.BorderSizePixel = 0
Example_3.Size = UDim2.new(0, 10, 0, 20)
Example_3.Visible = false
Example_3.ZIndex = 10
table.insert(shade2,Example_3)

Text_4.Name = "Text"
Text_4.Parent = Example_3
Text_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_4.BorderSizePixel = 0
Text_4.Position = UDim2.new(0, 10, 0, 0)
Text_4.Size = UDim2.new(0, 240, 0, 20)
Text_4.Font = Enum.Font.SourceSans
Text_4.TextSize = 14
Text_4.Text = "honk"
Text_4.TextColor3 = Color3.new(1, 1, 1)
Text_4.TextXAlignment = Enum.TextXAlignment.Left
Text_4.ZIndex = 10
table.insert(shade2,Text_4)
table.insert(text1,Text_4)

Delete_4.Name = "Delete"
Delete_4.Parent = Text_4
Delete_4.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_4.BorderSizePixel = 0
Delete_4.Position = UDim2.new(0, 200, 0, 0)
Delete_4.Size = UDim2.new(0, 40, 0, 20)
Delete_4.Font = Enum.Font.SourceSans
Delete_4.TextSize = 14
Delete_4.Text = "Delete"
Delete_4.TextColor3 = Color3.new(0, 0, 0)
Delete_4.ZIndex = 10
table.insert(shade3,Delete_4)
table.insert(text2,Delete_4)

PluginsFrame.Name = "PluginsFrame"
PluginsFrame.Parent = Settings
PluginsFrame.Active = true
PluginsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PluginsFrame.BorderSizePixel = 0
PluginsFrame.Position = UDim2.new(0, 0, 0, 200)
PluginsFrame.Size = UDim2.new(0, 250, 0, 200)
PluginsFrame.ZIndex = 10
table.insert(shade1,PluginsFrame)

Close_4.Name = "Close"
Close_4.Parent = PluginsFrame
Close_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_4.BorderSizePixel = 0
Close_4.Position = UDim2.new(0, 205, 0, 175)
Close_4.Size = UDim2.new(0, 40, 0, 20)
Close_4.Font = Enum.Font.SourceSans
Close_4.TextSize = 14
Close_4.Text = "Close"
Close_4.TextColor3 = Color3.new(1, 1, 1)
Close_4.ZIndex = 10
table.insert(shade2,Close_4)
table.insert(text1,Close_4)

Add_3.Name = "Add"
Add_3.Parent = PluginsFrame
Add_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_3.BorderSizePixel = 0
Add_3.Position = UDim2.new(0, 5, 0, 175)
Add_3.Size = UDim2.new(0, 40, 0, 20)
Add_3.Font = Enum.Font.SourceSans
Add_3.TextSize = 14
Add_3.Text = "Add"
Add_3.TextColor3 = Color3.new(1, 1, 1)
Add_3.ZIndex = 10
table.insert(shade2,Add_3)
table.insert(text1,Add_3)

Holder_5.Name = "Holder"
Holder_5.Parent = PluginsFrame
Holder_5.BackgroundTransparency = 1
Holder_5.BorderSizePixel = 0
Holder_5.Position = UDim2.new(0, 0, 0, 0)
Holder_5.Selectable = false
Holder_5.Size = UDim2.new(0, 250, 0, 170)
Holder_5.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_5.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_5.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.ScrollBarThickness = 0
Holder_5.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.VerticalScrollBarInset = 'Always'
Holder_5.ZIndex = 10

Example_5.Name = "Example"
Example_5.Parent = PluginsFrame
Example_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_5.BorderSizePixel = 0
Example_5.Size = UDim2.new(0, 10, 0, 20)
Example_5.Visible = false
Example_5.ZIndex = 10
table.insert(shade2,Example_5)

Text_6.Name = "Text"
Text_6.Parent = Example_5
Text_6.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_6.BorderSizePixel = 0
Text_6.Position = UDim2.new(0, 10, 0, 0)
Text_6.Size = UDim2.new(0, 240, 0, 20)
Text_6.Font = Enum.Font.SourceSans
Text_6.TextSize = 14
Text_6.Text = "F4 > Toggle Fly"
Text_6.TextColor3 = Color3.new(1, 1, 1)
Text_6.TextXAlignment = Enum.TextXAlignment.Left
Text_6.ZIndex = 10
table.insert(shade2,Text_6)
table.insert(text1,Text_6)

Delete_7.Name = "Delete"
Delete_7.Parent = Text_6
Delete_7.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_7.BorderSizePixel = 0
Delete_7.Position = UDim2.new(0, 200, 0, 0)
Delete_7.Size = UDim2.new(0, 40, 0, 20)
Delete_7.Font = Enum.Font.SourceSans
Delete_7.TextSize = 14
Delete_7.Text = "Delete"
Delete_7.TextColor3 = Color3.new(0, 0, 0)
Delete_7.ZIndex = 10
table.insert(shade3,Delete_7)
table.insert(text2,Delete_7)

PluginEditor.Name = randomString()
PluginEditor.Parent = ScaledHolder
PluginEditor.BorderSizePixel = 0
PluginEditor.Active = true
PluginEditor.BackgroundTransparency = 1
PluginEditor.Position = UDim2.new(0.5, -180, 0, -500)
PluginEditor.Size = UDim2.new(0, 360, 0, 20)
PluginEditor.ZIndex = 10

background_3.Name = "background"
background_3.Parent = PluginEditor
background_3.Active = true
background_3.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_3.BorderSizePixel = 0
background_3.Position = UDim2.new(0, 0, 0, 20)
background_3.Size = UDim2.new(0, 360, 0, 160)
background_3.ZIndex = 10
table.insert(shade1,background_3)

Dark_2.Name = "Dark"
Dark_2.Parent = background_3
Dark_2.Active = true
Dark_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_2.BorderSizePixel = 0
Dark_2.Position = UDim2.new(0, 222, 0, 0)
Dark_2.Size = UDim2.new(0, 2, 0, 160)
Dark_2.ZIndex = 10
table.insert(shade2,Dark_2)

Img.Name = "Img"
Img.Parent = background_3
Img.BackgroundTransparency = 1
Img.Position = UDim2.new(0, 242, 0, 3)
Img.Size = UDim2.new(0, 100, 0, 95)
Img.Image = getcustomasset("infiniteyield/assets/imgstudiopluginlogo.png")
Img.ZIndex = 10

AddPlugin.Name = "AddPlugin"
AddPlugin.Parent = background_3
AddPlugin.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AddPlugin.BorderSizePixel = 0
AddPlugin.Position = UDim2.new(0, 235, 0, 100)
AddPlugin.Size = UDim2.new(0, 115, 0, 50)
AddPlugin.Font = Enum.Font.SourceSans
AddPlugin.TextSize = 14
AddPlugin.Text = "Add Plugin"
AddPlugin.TextColor3 = Color3.new(1, 1, 1)
AddPlugin.ZIndex = 10
table.insert(shade2,AddPlugin)
table.insert(text1,AddPlugin)

FileName.Name = "FileName"
FileName.Parent = background_3
FileName.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FileName.BorderSizePixel = 0
FileName.Position = UDim2.new(0.028, 0, 0.625, 0)
FileName.Size = UDim2.new(0, 200, 0, 50)
FileName.Font = Enum.Font.SourceSans
FileName.TextSize = 14
FileName.Text = "Plugin File Name"
FileName.TextColor3 = Color3.new(1, 1, 1)
FileName.ZIndex = 10
table.insert(shade2,FileName)
table.insert(text1,FileName)

About.Name = "About"
About.Parent = background_3
About.BackgroundTransparency = 1
About.BorderSizePixel = 0
About.Position = UDim2.new(0, 17, 0, 10)
About.Size = UDim2.new(0, 187, 0, 49)
About.Font = Enum.Font.SourceSans
About.TextSize = 14
About.Text = "Plugins are .iy files and should be located in the 'workspace' folder of your exploit."
About.TextColor3 = Color3.fromRGB(255, 255, 255)
About.TextWrapped = true
About.TextYAlignment = Enum.TextYAlignment.Top
About.ZIndex = 10
table.insert(text1,About)

Directions_2.Name = "Directions"
Directions_2.Parent = background_3
Directions_2.BackgroundTransparency = 1
Directions_2.BorderSizePixel = 0
Directions_2.Position = UDim2.new(0, 17, 0, 60)
Directions_2.Size = UDim2.new(0, 187, 0, 49)
Directions_2.Font = Enum.Font.SourceSans
Directions_2.TextSize = 14
Directions_2.Text = "Type the name of the plugin file you want to add below."
Directions_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions_2.TextWrapped = true
Directions_2.TextYAlignment = Enum.TextYAlignment.Top
Directions_2.ZIndex = 10
table.insert(text1,Directions_2)

shadow_3.Name = "shadow"
shadow_3.Parent = PluginEditor
shadow_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_3.BorderSizePixel = 0
shadow_3.Size = UDim2.new(0, 360, 0, 20)
shadow_3.ZIndex = 10
table.insert(shade2,shadow_3)

PopupText_3.Name = "PopupText"
PopupText_3.Parent = shadow_3
PopupText_3.BackgroundTransparency = 1
PopupText_3.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_3.ZIndex = 10
PopupText_3.Font = Enum.Font.SourceSans
PopupText_3.TextSize = 14
PopupText_3.Text = "Add Plugins"
PopupText_3.TextColor3 = Color3.new(1, 1, 1)
PopupText_3.TextWrapped = true
table.insert(text1,PopupText_3)

Exit_3.Name = "Exit"
Exit_3.Parent = shadow_3
Exit_3.BackgroundTransparency = 1
Exit_3.Position = UDim2.new(1, -20, 0, 0)
Exit_3.Size = UDim2.new(0, 20, 0, 20)
Exit_3.Text = ""
Exit_3.ZIndex = 10

ExitImage_3.Parent = Exit_3
ExitImage_3.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_3.BackgroundTransparency = 1
ExitImage_3.Position = UDim2.new(0, 5, 0, 5)
ExitImage_3.Size = UDim2.new(0, 10, 0, 10)
ExitImage_3.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_3.ZIndex = 10

AliasHint.Name = "AliasHint"
AliasHint.Parent = AliasesFrame
AliasHint.BackgroundTransparency = 1
AliasHint.BorderSizePixel = 0
AliasHint.Position = UDim2.new(0, 25, 0, 40)
AliasHint.Size = UDim2.new(0, 200, 0, 50)
AliasHint.Font = Enum.Font.SourceSansItalic
AliasHint.TextSize = 16
AliasHint.Text = "Use Add to create a new alias"
AliasHint.TextColor3 = Color3.new(1, 1, 1)
AliasHint.TextStrokeColor3 = Color3.new(1, 1, 1)
AliasHint.TextWrapped = true
AliasHint.ZIndex = 10
table.insert(text1,AliasHint)

PluginsHint.Name = "PluginsHint"
PluginsHint.Parent = PluginsFrame
PluginsHint.BackgroundTransparency = 1
PluginsHint.BorderSizePixel = 0
PluginsHint.Position = UDim2.new(0, 25, 0, 40)
PluginsHint.Size = UDim2.new(0, 200, 0, 50)
PluginsHint.Font = Enum.Font.SourceSansItalic
PluginsHint.TextSize = 16
PluginsHint.Text = "Download plugins from the IY Discord (discord.gg/78ZuWSq)"
PluginsHint.TextColor3 = Color3.new(1, 1, 1)
PluginsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PluginsHint.TextWrapped = true
PluginsHint.ZIndex = 10
table.insert(text1,PluginsHint)

PositionsHint.Name = "PositionsHint"
PositionsHint.Parent = PositionsFrame
PositionsHint.BackgroundTransparency = 1
PositionsHint.BorderSizePixel = 0
PositionsHint.Position = UDim2.new(0, 25, 0, 40)
PositionsHint.Size = UDim2.new(0, 200, 0, 70)
PositionsHint.Font = Enum.Font.SourceSansItalic
PositionsHint.TextSize = 16
PositionsHint.Text = "Use the 'swp' or 'setwaypoint' command to add a position using your character (NOTE: Part teleports will not save)"
PositionsHint.TextColor3 = Color3.new(1, 1, 1)
PositionsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PositionsHint.TextWrapped = true
PositionsHint.ZIndex = 10
table.insert(text1,PositionsHint)

-- Dedicated confirmation page: saved waypoints are cleared only after Confirm.
WaypointClearConfirmFrame.Name = "WaypointClearConfirmFrame"
WaypointClearConfirmFrame.Parent = Settings
WaypointClearConfirmFrame.Active = true
WaypointClearConfirmFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
WaypointClearConfirmFrame.BorderSizePixel = 0
WaypointClearConfirmFrame.Position = UDim2.new(0, 0, 0, 200)
WaypointClearConfirmFrame.Size = UDim2.new(0, 250, 0, 200)
WaypointClearConfirmFrame.Visible = false
WaypointClearConfirmFrame.ZIndex = 30
table.insert(shade1, WaypointClearConfirmFrame)

WaypointClearConfirmTitle.Name = "Title"
WaypointClearConfirmTitle.Parent = WaypointClearConfirmFrame
WaypointClearConfirmTitle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointClearConfirmTitle.BorderSizePixel = 0
WaypointClearConfirmTitle.Position = UDim2.new(0, 0, 0, 0)
WaypointClearConfirmTitle.Size = UDim2.new(1, 0, 0, 22)
WaypointClearConfirmTitle.Font = Enum.Font.SourceSans
WaypointClearConfirmTitle.TextSize = 14
WaypointClearConfirmTitle.Text = "Clear all waypoints?"
WaypointClearConfirmTitle.TextColor3 = Color3.new(1, 1, 1)
WaypointClearConfirmTitle.ZIndex = 31
table.insert(shade2, WaypointClearConfirmTitle)
table.insert(text1, WaypointClearConfirmTitle)

WaypointClearConfirmMessage.Name = "Message"
WaypointClearConfirmMessage.Parent = WaypointClearConfirmFrame
WaypointClearConfirmMessage.BackgroundTransparency = 1
WaypointClearConfirmMessage.BorderSizePixel = 0
WaypointClearConfirmMessage.Position = UDim2.new(0, 10, 0, 48)
WaypointClearConfirmMessage.Size = UDim2.new(1, -20, 0, 65)
WaypointClearConfirmMessage.Font = Enum.Font.SourceSans
WaypointClearConfirmMessage.TextSize = 14
WaypointClearConfirmMessage.Text = "This will remove all saved waypoints.\nDo you want to continue?"
WaypointClearConfirmMessage.TextColor3 = Color3.new(1, 1, 1)
WaypointClearConfirmMessage.TextWrapped = true
WaypointClearConfirmMessage.TextXAlignment = Enum.TextXAlignment.Center
WaypointClearConfirmMessage.TextYAlignment = Enum.TextYAlignment.Center
WaypointClearConfirmMessage.ZIndex = 31
table.insert(text1, WaypointClearConfirmMessage)

WaypointClearConfirmButton.Name = "Confirm"
WaypointClearConfirmButton.Parent = WaypointClearConfirmFrame
WaypointClearConfirmButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointClearConfirmButton.BorderSizePixel = 0
WaypointClearConfirmButton.Position = UDim2.new(0, 25, 0, 175)
WaypointClearConfirmButton.Size = UDim2.new(0, 90, 0, 20)
WaypointClearConfirmButton.Font = Enum.Font.SourceSans
WaypointClearConfirmButton.TextSize = 14
WaypointClearConfirmButton.Text = "Confirm"
WaypointClearConfirmButton.TextColor3 = Color3.new(1, 1, 1)
WaypointClearConfirmButton.ZIndex = 32
table.insert(shade2, WaypointClearConfirmButton)
table.insert(text1, WaypointClearConfirmButton)

WaypointClearCancelButton.Name = "Cancel"
WaypointClearCancelButton.Parent = WaypointClearConfirmFrame
WaypointClearCancelButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointClearCancelButton.BorderSizePixel = 0
WaypointClearCancelButton.Position = UDim2.new(0, 135, 0, 175)
WaypointClearCancelButton.Size = UDim2.new(0, 90, 0, 20)
WaypointClearCancelButton.Font = Enum.Font.SourceSans
WaypointClearCancelButton.TextSize = 14
WaypointClearCancelButton.Text = "Cancel"
WaypointClearCancelButton.TextColor3 = Color3.new(1, 1, 1)
WaypointClearCancelButton.ZIndex = 32
table.insert(shade2, WaypointClearCancelButton)
table.insert(text1, WaypointClearCancelButton)

-- Waypoint creation page, styled to match the Add Alias dialog.
WaypointAddDialog.Name = "WaypointAddDialog"
WaypointAddDialog.Parent = Settings
WaypointAddDialog.Active = true
WaypointAddDialog.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
WaypointAddDialog.BorderSizePixel = 0
WaypointAddDialog.Position = UDim2.new(0, 0, 0, 200)
WaypointAddDialog.Size = UDim2.new(0, 250, 0, 162)
WaypointAddDialog.Visible = false
WaypointAddDialog.ZIndex = 30
table.insert(shade1, WaypointAddDialog)

WaypointAddDialogTitle.Name = "Title"
WaypointAddDialogTitle.Parent = WaypointAddDialog
WaypointAddDialogTitle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointAddDialogTitle.BorderSizePixel = 0
WaypointAddDialogTitle.Position = UDim2.new(0, 0, 0, 0)
WaypointAddDialogTitle.Size = UDim2.new(1, 0, 0, 24)
WaypointAddDialogTitle.Font = Enum.Font.SourceSans
WaypointAddDialogTitle.TextSize = 14
WaypointAddDialogTitle.Text = "Add Waypoint"
WaypointAddDialogTitle.TextColor3 = Color3.new(1, 1, 1)
WaypointAddDialogTitle.ZIndex = 31
table.insert(shade2, WaypointAddDialogTitle)
table.insert(text1, WaypointAddDialogTitle)

WaypointNameInput.Name = "WaypointNameInput"
WaypointNameInput.Parent = WaypointAddDialog
WaypointNameInput.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointNameInput.BorderSizePixel = 0
WaypointNameInput.ClearTextOnFocus = false
WaypointNameInput.Position = UDim2.new(0, 8, 0, 44)
WaypointNameInput.Size = UDim2.new(1, -16, 0, 26)
WaypointNameInput.Font = Enum.Font.SourceSans
WaypointNameInput.TextSize = 14
WaypointNameInput.Text = ""
WaypointNameInput.PlaceholderText = "Waypoint name (optional)"
WaypointNameInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
WaypointNameInput.TextColor3 = Color3.new(1, 1, 1)
WaypointNameInput.TextXAlignment = Enum.TextXAlignment.Left
WaypointNameInput.ZIndex = 31
table.insert(shade2, WaypointNameInput)
table.insert(text1, WaypointNameInput)

WaypointNameHint.Name = "WaypointNameHint"
WaypointNameHint.Parent = WaypointAddDialog
WaypointNameHint.BackgroundTransparency = 1
WaypointNameHint.BorderSizePixel = 0
WaypointNameHint.Position = UDim2.new(0, 8, 0, 76)
WaypointNameHint.Size = UDim2.new(1, -16, 0, 30)
WaypointNameHint.Font = Enum.Font.SourceSansItalic
WaypointNameHint.TextSize = 12
WaypointNameHint.Text = "Leave blank for the next available name (a, b, c...)."
WaypointNameHint.TextColor3 = Color3.fromRGB(180, 180, 180)
WaypointNameHint.TextWrapped = true
WaypointNameHint.TextXAlignment = Enum.TextXAlignment.Left
WaypointNameHint.TextYAlignment = Enum.TextYAlignment.Center
WaypointNameHint.ZIndex = 31
table.insert(text1, WaypointNameHint)

WaypointAddDone.Name = "Done"
WaypointAddDone.Parent = WaypointAddDialog
WaypointAddDone.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointAddDone.BorderSizePixel = 0
WaypointAddDone.Position = UDim2.new(0, 25, 0, 128)
WaypointAddDone.Size = UDim2.new(0, 90, 0, 22)
WaypointAddDone.Font = Enum.Font.SourceSans
WaypointAddDone.TextSize = 14
WaypointAddDone.Text = "Done"
WaypointAddDone.TextColor3 = Color3.new(1, 1, 1)
WaypointAddDone.ZIndex = 32
table.insert(shade2, WaypointAddDone)
table.insert(text1, WaypointAddDone)

WaypointAddCancel.Name = "Cancel"
WaypointAddCancel.Parent = WaypointAddDialog
WaypointAddCancel.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointAddCancel.BorderSizePixel = 0
WaypointAddCancel.Position = UDim2.new(0, 135, 0, 128)
WaypointAddCancel.Size = UDim2.new(0, 90, 0, 22)
WaypointAddCancel.Font = Enum.Font.SourceSans
WaypointAddCancel.TextSize = 14
WaypointAddCancel.Text = "Cancel"
WaypointAddCancel.TextColor3 = Color3.new(1, 1, 1)
WaypointAddCancel.ZIndex = 32
table.insert(shade2, WaypointAddCancel)
table.insert(text1, WaypointAddCancel)

-- Floating waypoint hover panel template; each opened Waypoint gets its own clone.
local waypointHoverFrames = {}
WaypointHoverFrame.Name = "WaypointHoverFrameTemplate"
WaypointHoverFrame.Parent = PARENT
WaypointHoverFrame.Active = true
WaypointHoverFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
WaypointHoverFrame.BorderSizePixel = 1
WaypointHoverFrame.BorderColor3 = Color3.fromRGB(78, 78, 79)
WaypointHoverFrame.ClipsDescendants = true
WaypointHoverFrame.AnchorPoint = Vector2.new(0, 0)
WaypointHoverFrame.Position = UDim2.new(1, -82, 0, 45)
WaypointHoverFrame.Size = UDim2.new(0, 66, 0, 38)
WaypointHoverFrame.Visible = false
WaypointHoverFrame.ZIndex = 80
table.insert(shade1, WaypointHoverFrame)
table.insert(waypointHoverFrames, WaypointHoverFrame)
-- The floating Waypoint window keeps the original compact layout with sharp corners.
-- BackTP is controlled centrally in the Edit/Goto Waypoints panel, not per window.
WaypointHoverHeader.Name = "Header"
WaypointHoverHeader.Parent = WaypointHoverFrame
WaypointHoverHeader.BackgroundTransparency = 1
WaypointHoverHeader.BorderSizePixel = 0
WaypointHoverHeader.Position = UDim2.new(0, 0, 0, 0)
WaypointHoverHeader.Size = UDim2.new(0, 0, 0, 0)
WaypointHoverHeader.Visible = false
WaypointHoverHeader.Text = ""
WaypointHoverHeader.ZIndex = 81

WaypointHoverClose.Name = "Close"
WaypointHoverClose.Parent = WaypointHoverFrame
WaypointHoverClose.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointHoverClose.BackgroundTransparency = 1
WaypointHoverClose.BorderSizePixel = 0
WaypointHoverClose.AutoButtonColor = false
WaypointHoverClose.Position = UDim2.new(1, -17, 0, 0)
WaypointHoverClose.Size = UDim2.new(0, 17, 0, 17)
WaypointHoverClose.Font = Enum.Font.SourceSansBold
WaypointHoverClose.TextSize = 14
WaypointHoverClose.Text = "X"
WaypointHoverClose.TextColor3 = Color3.new(1, 1, 1)
WaypointHoverClose.ZIndex = 84
table.insert(shade2, WaypointHoverClose)
table.insert(text1, WaypointHoverClose)

WaypointHoverButton.Name = "GotoWaypoint"
WaypointHoverButton.Parent = WaypointHoverFrame
WaypointHoverButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
WaypointHoverButton.BorderSizePixel = 0
WaypointHoverButton.AutoButtonColor = false
WaypointHoverButton.Position = UDim2.new(0, 0, 0, 0)
WaypointHoverButton.Size = UDim2.new(1, 0, 1, 0)
WaypointHoverButton.Font = Enum.Font.SourceSansBold
WaypointHoverButton.TextSize = 16
WaypointHoverButton.Text = "Waypoint"
WaypointHoverButton.TextColor3 = Color3.new(1, 1, 1)
WaypointHoverButton.TextScaled = true
WaypointHoverButton.TextXAlignment = Enum.TextXAlignment.Center
WaypointHoverButton.TextYAlignment = Enum.TextYAlignment.Center
WaypointHoverButton.TextWrapped = true
WaypointHoverButton.ZIndex = 81
table.insert(shade2, WaypointHoverButton)
table.insert(text1, WaypointHoverButton)
local waypointHoverTextConstraint = Instance.new("UITextSizeConstraint")
waypointHoverTextConstraint.MinTextSize = 9
waypointHoverTextConstraint.MaxTextSize = 18
waypointHoverTextConstraint.Parent = WaypointHoverButton
local waypointHoverButtonPadding = Instance.new("UIPadding")
waypointHoverButtonPadding.PaddingLeft = UDim.new(0, 3)
waypointHoverButtonPadding.PaddingRight = UDim.new(0, 3)
waypointHoverButtonPadding.Parent = WaypointHoverButton

ToPartFrame.Name = randomString()
ToPartFrame.Parent = ScaledHolder
ToPartFrame.Active = true
ToPartFrame.BackgroundTransparency = 1
ToPartFrame.Position = UDim2.new(0.5, -180, 0, -500)
ToPartFrame.Size = UDim2.new(0, 360, 0, 20)
ToPartFrame.ZIndex = 10

background_4.Name = "background"
background_4.Parent = ToPartFrame
background_4.Active = true
background_4.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_4.BorderSizePixel = 0
background_4.Position = UDim2.new(0, 0, 0, 20)
background_4.Size = UDim2.new(0, 360, 0, 117)
background_4.ZIndex = 10
table.insert(shade1,background_4)

ChoosePart.Name = "ChoosePart"
ChoosePart.Parent = background_4
ChoosePart.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ChoosePart.BorderSizePixel = 0
ChoosePart.Position = UDim2.new(0, 100, 0, 55)
ChoosePart.Size = UDim2.new(0, 75, 0, 30)
ChoosePart.Font = Enum.Font.SourceSans
ChoosePart.TextSize = 14
ChoosePart.Text = "Select Part"
ChoosePart.TextColor3 = Color3.new(1, 1, 1)
ChoosePart.ZIndex = 10
table.insert(shade2,ChoosePart)
table.insert(text1,ChoosePart)

CopyPath.Name = "CopyPath"
CopyPath.Parent = background_4
CopyPath.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CopyPath.BorderSizePixel = 0
CopyPath.Position = UDim2.new(0, 185, 0, 55)
CopyPath.Size = UDim2.new(0, 75, 0, 30)
CopyPath.Font = Enum.Font.SourceSans
CopyPath.TextSize = 14
CopyPath.Text = "Copy Path"
CopyPath.TextColor3 = Color3.new(1, 1, 1)
CopyPath.ZIndex = 10
table.insert(shade2,CopyPath)
table.insert(text1,CopyPath)

Directions_3.Name = "Directions"
Directions_3.Parent = background_4
Directions_3.BackgroundTransparency = 1
Directions_3.BorderSizePixel = 0
Directions_3.Position = UDim2.new(0, 51, 0, 17)
Directions_3.Size = UDim2.new(0, 257, 0, 32)
Directions_3.Font = Enum.Font.SourceSans
Directions_3.TextSize = 14
Directions_3.Text = 'Click on a part and then click the "Select Part" button below to set it as a teleport location'
Directions_3.TextColor3 = Color3.new(1, 1, 1)
Directions_3.TextWrapped = true
Directions_3.TextYAlignment = Enum.TextYAlignment.Top
Directions_3.ZIndex = 10
table.insert(text1,Directions_3)

Path.Name = "Path"
Path.Parent = background_4
Path.BackgroundTransparency = 1
Path.BorderSizePixel = 0
Path.Position = UDim2.new(0, 0, 0, 94)
Path.Size = UDim2.new(0, 360, 0, 16)
Path.Font = Enum.Font.SourceSansItalic
Path.TextSize = 14
Path.Text = ""
Path.TextColor3 = Color3.new(1, 1, 1)
Path.TextScaled = true
Path.TextWrapped = true
Path.TextYAlignment = Enum.TextYAlignment.Top
Path.ZIndex = 10
table.insert(text1,Path)

shadow_4.Name = "shadow"
shadow_4.Parent = ToPartFrame
shadow_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_4.BorderSizePixel = 0
shadow_4.Size = UDim2.new(0, 360, 0, 20)
shadow_4.ZIndex = 10
table.insert(shade2,shadow_4)

PopupText_5.Name = "PopupText"
PopupText_5.Parent = shadow_4
PopupText_5.BackgroundTransparency = 1
PopupText_5.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_5.ZIndex = 10
PopupText_5.Font = Enum.Font.SourceSans
PopupText_5.TextSize = 14
PopupText_5.Text = "Teleport to Part"
PopupText_5.TextColor3 = Color3.new(1, 1, 1)
PopupText_5.TextWrapped = true
table.insert(text1,PopupText_5)

Exit_4.Name = "Exit"
Exit_4.Parent = shadow_4
Exit_4.BackgroundTransparency = 1
Exit_4.Position = UDim2.new(1, -20, 0, 0)
Exit_4.Size = UDim2.new(0, 20, 0, 20)
Exit_4.Text = ""
Exit_4.ZIndex = 10

ExitImage_5.Parent = Exit_4
ExitImage_5.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_5.BackgroundTransparency = 1
ExitImage_5.Position = UDim2.new(0, 5, 0, 5)
ExitImage_5.Size = UDim2.new(0, 10, 0, 10)
ExitImage_5.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_5.ZIndex = 10

logs.Name = randomString()
logs.Parent = ScaledHolder
logs.Active = true
logs.BackgroundTransparency = 1
logs.Position = UDim2.new(0, 0, 1, 10)
logs.Size = UDim2.new(0, 338, 0, 20)
logs.ZIndex = 10

shadow.Name = "shadow"
shadow.Parent = logs
shadow.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
shadow.BorderSizePixel = 0
shadow.Position = UDim2.new(0, 0, 0.00999999978, 0)
shadow.Size = UDim2.new(0, 338, 0, 20)
shadow.ZIndex = 10
table.insert(shade2,shadow)

Hide.Name = "Hide"
Hide.Parent = shadow
Hide.BackgroundTransparency = 1
Hide.Position = UDim2.new(1, -40, 0, 0)
Hide.Size = UDim2.new(0, 20, 0, 20)
Hide.ZIndex = 10
Hide.Text = ""

ImageLabel.Parent = Hide
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 3, 0, 3)
ImageLabel.Size = UDim2.new(0, 14, 0, 14)
ImageLabel.Image = getcustomasset("infiniteyield/assets/minimize.png")
ImageLabel.ZIndex = 10

PopupText.Name = "PopupText"
PopupText.Parent = shadow
PopupText.BackgroundTransparency = 1
PopupText.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText.ZIndex = 10
PopupText.Font = Enum.Font.SourceSans
PopupText.FontSize = Enum.FontSize.Size14
PopupText.Text = "Logs"
PopupText.TextColor3 = Color3.new(1, 1, 1)
PopupText.TextWrapped = true
table.insert(text1,PopupText)

Exit.Name = "Exit"
Exit.Parent = shadow
Exit.BackgroundTransparency = 1
Exit.Position = UDim2.new(1, -20, 0, 0)
Exit.Size = UDim2.new(0, 20, 0, 20)
Exit.ZIndex = 10
Exit.Text = ""

ImageLabel_2.Parent = Exit
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 10, 0, 10)
ImageLabel_2.Image = getcustomasset("infiniteyield/assets/close.png")
ImageLabel_2.ZIndex = 10

background.Name = "background"
background.Parent = logs
background.Active = true
background.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
background.BorderSizePixel = 0
background.ClipsDescendants = true
background.Position = UDim2.new(0, 0, 1, 0)
background.Size = UDim2.new(0, 338, 0, 245)
background.ZIndex = 10

chat.Name = "chat"
chat.Parent = background
chat.Active = true
chat.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
chat.BorderSizePixel = 0
chat.ClipsDescendants = true
chat.Size = UDim2.new(0, 338, 0, 245)
chat.ZIndex = 10
table.insert(shade1,chat)

Clear.Name = "Clear"
Clear.Parent = chat
Clear.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear.BorderSizePixel = 0
Clear.Position = UDim2.new(0, 5, 0, 220)
Clear.Size = UDim2.new(0, 50, 0, 20)
Clear.ZIndex = 10
Clear.Font = Enum.Font.SourceSans
Clear.FontSize = Enum.FontSize.Size14
Clear.Text = "Clear"
Clear.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear)
table.insert(text1,Clear)

SaveChatlogs.Name = "SaveChatlogs"
SaveChatlogs.Parent = chat
SaveChatlogs.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
SaveChatlogs.BorderSizePixel = 0
SaveChatlogs.Position = UDim2.new(0, 258, 0, 220)
SaveChatlogs.Size = UDim2.new(0, 75, 0, 20)
SaveChatlogs.ZIndex = 10
SaveChatlogs.Font = Enum.Font.SourceSans
SaveChatlogs.FontSize = Enum.FontSize.Size14
SaveChatlogs.Text = "Save To .txt"
SaveChatlogs.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,SaveChatlogs)
table.insert(text1,SaveChatlogs)

Toggle.Name = "Toggle"
Toggle.Parent = chat
Toggle.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 60, 0, 220)
Toggle.Size = UDim2.new(0, 66, 0, 20)
Toggle.ZIndex = 10
Toggle.Font = Enum.Font.SourceSans
Toggle.FontSize = Enum.FontSize.Size14
Toggle.Text = "Disabled"
Toggle.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle)
table.insert(text1,Toggle)

scroll_2.Name = "scroll"
scroll_2.Parent = chat
scroll_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_2.BorderSizePixel = 0
scroll_2.Position = UDim2.new(0, 5, 0, 25)
scroll_2.Size = UDim2.new(0, 328, 0, 190)
scroll_2.ZIndex = 10
scroll_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_2.ScrollBarThickness = 8
scroll_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_2)
table.insert(shade2,scroll_2)

join.Name = "join"
join.Parent = background
join.Active = true
join.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
join.BorderSizePixel = 0
join.ClipsDescendants = true
join.Size = UDim2.new(0, 338, 0, 245)
join.Visible = false
join.ZIndex = 10
table.insert(shade1,join)

Toggle_2.Name = "Toggle"
Toggle_2.Parent = join
Toggle_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle_2.BorderSizePixel = 0
Toggle_2.Position = UDim2.new(0, 60, 0, 220)
Toggle_2.Size = UDim2.new(0, 66, 0, 20)
Toggle_2.ZIndex = 10
Toggle_2.Font = Enum.Font.SourceSans
Toggle_2.FontSize = Enum.FontSize.Size14
Toggle_2.Text = "Disabled"
Toggle_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle_2)
table.insert(text1,Toggle_2)

Clear_2.Name = "Clear"
Clear_2.Parent = join
Clear_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear_2.BorderSizePixel = 0
Clear_2.Position = UDim2.new(0, 5, 0, 220)
Clear_2.Size = UDim2.new(0, 50, 0, 20)
Clear_2.ZIndex = 10
Clear_2.Font = Enum.Font.SourceSans
Clear_2.FontSize = Enum.FontSize.Size14
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear_2)
table.insert(text1,Clear_2)

scroll_3.Name = "scroll"
scroll_3.Parent = join
scroll_3.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_3.BorderSizePixel = 0
scroll_3.Position = UDim2.new(0, 5, 0, 25)
scroll_3.Size = UDim2.new(0, 328, 0, 190)
scroll_3.ZIndex = 10
scroll_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_3.ScrollBarThickness = 8
scroll_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_3)
table.insert(shade2,scroll_3)

selectChat.Name = "selectChat"
selectChat.Parent = background
selectChat.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
selectChat.BorderSizePixel = 0
selectChat.Position = UDim2.new(0, 5, 0, 5)
selectChat.Size = UDim2.new(0, 164, 0, 20)
selectChat.ZIndex = 10
selectChat.Font = Enum.Font.SourceSans
selectChat.FontSize = Enum.FontSize.Size14
selectChat.Text = "Chat Logs"
selectChat.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,selectChat)
table.insert(text1,selectChat)

selectJoin.Name = "selectJoin"
selectJoin.Parent = background
selectJoin.BackgroundColor3 = Color3.new(0.305882, 0.305882, 0.309804)
selectJoin.BorderSizePixel = 0
selectJoin.Position = UDim2.new(0, 169, 0, 5)
selectJoin.Size = UDim2.new(0, 164, 0, 20)
selectJoin.ZIndex = 10
selectJoin.Font = Enum.Font.SourceSans
selectJoin.FontSize = Enum.FontSize.Size14
selectJoin.Text = "Join Logs"
selectJoin.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade3,selectJoin)
table.insert(text1,selectJoin)

function create(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				local referencedInstance = insts[val[1]]
				local assigned, assignError = pcall(function()
					insts[v[1]][prop] = referencedInstance
				end)
				if not assigned then
					warn("Infinite Yield Cruzan: could not set GUI property " .. tostring(prop) .. ": " .. tostring(assignError))
				end
			else
				-- Older serialized UI tables encode Font as its legacy numeric enum value.
				-- Convert it to Enum.Font when required by the current Roblox API.
				if prop == "Font" and type(val) == "number" then
					pcall(function()
						for _, fontItem in ipairs(Enum.Font:GetEnumItems()) do
							if fontItem.Value == val then
								val = fontItem
								break
							end
						end
					end)
				end
				local assigned, assignError = pcall(function()
					insts[v[1]][prop] = val
				end)
				if not assigned then
					-- A nonessential UI property from an older serializer must not abort
					-- the full script start; leave that property at its Roblox default.
					warn("Infinite Yield Cruzan: skipped unsupported GUI property " .. tostring(prop) ..
						" on " .. tostring(v[2]) .. ": " .. tostring(assignError))
				end
			end
		end
	end

	return insts[1]
end

ViewportTextBox = (function()

	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
		textbox.Parent = view

		return obj
	end

	return {convert = convert}
end)()

CmdbarView = ViewportTextBox.convert(Cmdbar).View
CmdbarView.ZIndex = 10
CmdbarView.BackgroundColor3 = Holder.BackgroundColor3
CmdbarView.BackgroundTransparency = 0
ViewportTextBox.convert(Cmdbar_2).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_3).View.ZIndex = 10

function writefileExploit()
	if writefile then
		return true
	end
end

function readfileExploit()
	if readfile then
		return true
	end
end

function isNumber(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

function vtype(o, t)
	if o == nil then return false end
	if type(o) == "userdata" then return typeof(o) == t end
	return type(o) == t
end

function getRoot(char)
	if char and char:FindFirstChildOfClass("Humanoid") then
		return char:FindFirstChildOfClass("Humanoid").RootPart
	else
		return nil
	end
end

function tools(plr)
	if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or plr.Character:FindFirstChildOfClass("Tool") then
		return true
	end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function breakVelocity()
    local V3 = Vector3.new(0, 0, 0)
    for _, v in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = V3, V3
        end
    end
end

function toClipboard(txt)
	if everyClipboard then
		everyClipboard(tostring(txt)) -- some executor errored without tostring btw so dont call me out for this
		notify("Clipboard", "Copied to clipboard")
	else
		notify("Clipboard", "Your exploit doesn't have the ability to use the clipboard")
	end
end

function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj
	local service = ''

	if getS.Parent ~= game then
		repeat
			getS = getS.Parent
			service = getS.ClassName
		until getS.Parent == game
	end

	if parent.Parent ~= getS then
		repeat
			parent = parent.Parent
			if string.find(tostring(parent),' ') then
				if period then
					fullname = '["'..parent.Name..'"].'..fullname
				else
					fullname = '["'..parent.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = parent.Name..'.'..fullname
				else
					fullname = parent.Name..''..fullname
				end
				period = true
			end
		until parent.Parent == getS
	elseif string.find(tostring(parent),' ') then
		fullname = '["'..parent.Name..'"]'
		period = false
	end

	if period then
		return 'game:GetService("'..service..'").'..fullname
	else
		return 'game:GetService("'..service..'")'..fullname
	end
end

AllWaypoints = {}

local cooldown = false
function writefileCooldown(name,data)
	task.spawn(function()
		if not cooldown then
			cooldown = true
			writefile(name, data, true)
		else
			repeat wait() until cooldown == false
			writefileCooldown(name,data)
		end
		wait(3)
		cooldown = false
	end)
end

function dragGUI(gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end))
	end)
end

dragGUI(logs)
dragGUI(KeybindEditor)
dragGUI(PluginEditor)
dragGUI(ToPartFrame)

eventEditor = (function()
	local events = {}

	local function registerEvent(name,sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local onEdited = nil

	local function fireEvent(name,...)
		local args = {...}
		local event = events[name]
		if event then
			for i,cmd in pairs(event.commands) do
				local metCondition = true
				for idx,set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet,Players.LocalPlayer),argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(),cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal)<=tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					pcall(task.spawn(function()
						local cmdStr = cmd[1]
						for count,arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$"..count,arg)
						end
						if cmdStr:lower():match("plugin") then return end
						wait(cmd[3] or 0)
						execCmd(cmdStr)
					end))
				end
			end
		end
	end

	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderSizePixel=0,Name="EventEditor",Position=UDim2.new(0.5,-175,0,-500),Size=UDim2.new(0,350,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=currentShade2,BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0.95,0),Text="Event Editor",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,202),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={6},Position=UDim2.new(0,5,0,5),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,-10,1,-10),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{8,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={7},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{9,"UIListLayout",{Parent={8},SortOrder=2,}},
		{10,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,ClipsDescendants=true,Name="Settings",Parent={6},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,150,1,0),ZIndex=10,}},
		{11,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),Name="Slider",Parent={10},Position=UDim2.new(0,-150,0,0),Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.23529413342476,0.23529413342476,0.23529413342476),BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="Line",Parent={11},Size=UDim2.new(0,1,1,0),ZIndex=10,}},
		{13,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={11},Position=UDim2.new(0,0,0,25),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,-25),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={13},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{15,"UIListLayout",{Parent={14},SortOrder=2,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={11},Size=UDim2.new(1,0,0,20),Text="Event Settings",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{17,"TextButton",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Font=3,Name="Close",BorderSizePixel=0,Parent={11},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="<",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{18,"Folder",{Name="Templates",Parent={10},}},
		{19,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Players",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,86),Visible=false,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={19},Size=UDim2.new(1,0,0,20),Text="Choose Players",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{21,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={19},Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-10,0,20),Text="Any Player",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{22,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={21},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{23,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={22},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{24,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Me",Parent={19},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Me Only",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{25,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={24},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{26,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={25},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{27,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={19},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Custom Player Set",Position=UDim2.new(0,5,0,64),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{28,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={19},Position=UDim2.new(1,-25,0,64),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{29,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={28},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Strings",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={30},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={30},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any String",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={32},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{34,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={33},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Numbers",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={54},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any Number",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={56},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{58,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={57},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{59,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={54},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Number",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={54},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{61,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={60},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{35,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={30},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Match String",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={30},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{37,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={36},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{38,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="DelayEditor",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,24),Visible=false,ZIndex=10,}},
		{39,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Font=3,Name="Secs",Parent={38},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),Position=UDim2.new(0,60,0,2),Size=UDim2.new(1,-65,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Label",Parent={39},Position=UDim2.new(0,-55,0,0),Size=UDim2.new(1,0,1,0),Text="Delay (s):",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{41,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="EventTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{42,"TextButton",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="Expand",Parent={41},Size=UDim2.new(0,20,0,20),Text=">",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="EventName",Parent={41},Position=UDim2.new(0,25,0,0),Size=UDim2.new(1,-25,0,20),Text="OnSpawn",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{44,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BorderSizePixel=0,BackgroundTransparency=1,ClipsDescendants=true,Name="Cmds",Parent={41},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Name="Add",Parent={44},Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{46,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={45},PlaceholderColor3=Color3.new(0.7843137383461,0.7843137383461,0.7843137383461),PlaceholderText="Add new command",Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{47,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={44},Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{48,"UIListLayout",{Parent={47},SortOrder=2,}},
		{49,"Frame",{currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="CmdTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{50,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={49},PlaceholderColor3=Color3.new(1,1,1),Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-45,0,20),Text="a\\b\\c\\d",TextColor3=currentText1,TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{51,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Delete",Parent={49},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="X",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{52,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Settings",Parent={49},Position=UDim2.new(1,-40,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{53,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/settings.png"),Parent={52},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),ZIndex=10,}},
	})
	main.Name = randomString()
	local mainFrame = main:WaitForChild("Content")
	local eventList = mainFrame:WaitForChild("List")
	local eventListHolder = eventList:WaitForChild("Holder")
	local cmdTemplate = mainFrame:WaitForChild("CmdTemplate")
	local eventTemplate = mainFrame:WaitForChild("EventTemplate")
	local settingsFrame = mainFrame:WaitForChild("Settings"):WaitForChild("Slider")
	local settingsTemplates = mainFrame.Settings:WaitForChild("Templates")
	local settingsList = settingsFrame:WaitForChild("List"):WaitForChild("Holder")
	table.insert(shade2,main.TopBar) table.insert(shade1,mainFrame) table.insert(shade2,eventTemplate)
	table.insert(text1,eventTemplate.EventName) table.insert(shade1,eventTemplate.Cmds.Add) table.insert(shade1,cmdTemplate)
	table.insert(text1,cmdTemplate.TextBox) table.insert(shade2,cmdTemplate.Delete) table.insert(shade2,cmdTemplate.Settings)
	table.insert(scroll,mainFrame.List) table.insert(shade1,settingsFrame) table.insert(shade2,settingsFrame.Line)
	table.insert(shade2,settingsFrame.Close) table.insert(scroll,settingsFrame.List) table.insert(shade2,settingsTemplates.DelayEditor.Secs)
	table.insert(text1,settingsTemplates.DelayEditor.Secs) table.insert(text1,settingsTemplates.DelayEditor.Secs.Label) table.insert(text1,settingsTemplates.Players.Title)
	table.insert(shade3,settingsTemplates.Players.CustomButton) table.insert(shade2,settingsTemplates.Players.Custom) table.insert(text1,settingsTemplates.Players.Custom)
	table.insert(shade3,settingsTemplates.Players.Any.Button) table.insert(shade3,settingsTemplates.Players.Me.Button) table.insert(text1,settingsTemplates.Players.Any)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Strings.Title) table.insert(text1,settingsTemplates.Strings.Any)
	table.insert(shade3,settingsTemplates.Strings.Any.Button) table.insert(shade3,settingsTemplates.Strings.CustomButton) table.insert(text1,settingsTemplates.Strings.Custom)
	table.insert(shade2,settingsTemplates.Strings.Custom)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Numbers.Title) table.insert(text1,settingsTemplates.Numbers.Any)
	table.insert(shade3,settingsTemplates.Numbers.Any.Button) table.insert(shade3,settingsTemplates.Numbers.CustomButton) table.insert(text1,settingsTemplates.Numbers.Custom)
	table.insert(shade2,settingsTemplates.Numbers.Custom)

	local tweenInf = TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)

	local currentlyEditingCmd = nil

	settingsFrame:WaitForChild("Close").MouseButton1Click:Connect(function()
		settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end)

	local function resizeList()
		local size = 0

		for i,v in pairs(eventListHolder:GetChildren()) do
			if v.Name == "EventTemplate" then
				size = size + 20
				if v.Expand.Rotation == 90 then
					size = size + 20*(1+(#events[v.EventName:GetAttribute("RawName")].commands or 0))
				end
			end
		end

		TweenService:Create(eventList,tweenInf,{CanvasSize = UDim2.new(0,0,0,size)}):Play()

		if size > eventList.AbsoluteSize.Y then
			eventListHolder.Size = UDim2.new(1,-8,1,0)
		else
			eventListHolder.Size = UDim2.new(1,0,1,0)
		end
	end

	local function resizeSettingsList()
		local size = 0

		for i,v in pairs(settingsList:GetChildren()) do
			if v:IsA("Frame") then
				size = size + v.AbsoluteSize.Y
			end
		end

		settingsList.Parent.CanvasSize = UDim2.new(0,0,0,size)

		if size > settingsList.Parent.AbsoluteSize.Y then
			settingsList.Size = UDim2.new(1,-8,1,0)
		else
			settingsList.Size = UDim2.new(1,0,1,0)
		end
	end

	local function setupCheckbox(button,callback)
		local enabled = button.On.BackgroundTransparency == 0

		local function update()
			button.On.BackgroundTransparency = (enabled and 0 or 1)
		end

		button.On.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			if callback then callback(enabled) end
		end)

		return {
			Toggle = function(nocall) enabled = not enabled update() if not nocall and callback then callback(enabled) end end,
			Enable = function(nocall) if enabled then return end enabled = true update()if not nocall and callback then callback(enabled) end end,
			Disable = function(nocall) if not enabled then return end enabled = false update()if not nocall and callback then callback(enabled) end end,
			IsEnabled = function() return enabled end
		}
	end

	local function openSettingsEditor(event,cmd)
		currentlyEditingCmd = cmd

		for i,v in pairs(settingsList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		local delayEditor = settingsTemplates.DelayEditor:Clone()
		delayEditor.Secs.FocusLost:Connect(function()
			cmd[3] = tonumber(delayEditor.Secs.Text) or 0
			delayEditor.Secs.Text = cmd[3]
			if onEdited then onEdited() end
		end)
		delayEditor.Secs.Text = cmd[3]
		delayEditor.Visible = true
		table.insert(shade2,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs.Label)
		delayEditor.Parent = settingsList

		for i,v in pairs(event.sets) do
			if v.Type == "Player" then
				local template = settingsTemplates.Players:Clone()
				template.Title.Text = v.Name or "Player"

				local me,any,custom

				me = setupCheckbox(template.Me.Button,function(on)
					if not on then return end
					any.Disable()
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					me.Disable()
					custom.Disable()
					cmd[2][i] = 1
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					me.Disable()
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					me:Enable()
				elseif cVal == 1 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(shade3,template.CustomButton)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.Me.Button)
				table.insert(text1,template.Any)
				table.insert(text1,template.Me)
				template.Parent = settingsList
			elseif v.Type == "String" then
				local template = settingsTemplates.Strings:Clone()
				template.Title.Text = v.Name or "String"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			elseif v.Type == "Number" then
				local template = settingsTemplates.Numbers:Clone()
				template.Title.Text = v.Name or "Number"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					cmd[2][i] = tonumber(customTextBox.Text) or 0
					customTextBox.Text = cmd[2][i]
					if custom:IsEnabled() then
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			end
		end
		resizeSettingsList()
		settingsFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end

	local function defaultSettings(ev)
		local res = {}

		for i,v in pairs(ev.sets) do
			if v.Type == "Player" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "String" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "Number" then
				res[#res+1] = v.Default or 0
			end
		end

		return res
	end

	local function refreshList()
		for i,v in pairs(eventListHolder:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		for name,event in pairs(events) do
			local eventF = eventTemplate:Clone()
			eventF.EventName.Text = name
			eventF.Visible = true
			eventF.EventName:SetAttribute("RawName", name)
			table.insert(shade2,eventF)
			table.insert(text1,eventF.EventName)
			table.insert(shade1,eventF.Cmds.Add)

			local expanded = false
			eventF.Expand.MouseButton1Down:Connect(function()
				expanded = not expanded
				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				eventF.Expand.Rotation = expanded and 90 or 0
				resizeList()
			end)

			local function refreshCommands()
				for i,v in pairs(eventF.Cmds.Holder:GetChildren()) do
					if v.Name == "CmdTemplate" then
						v:Destroy()
					end
				end

				eventF.EventName.Text = name..(#event.commands > 0 and " ("..#event.commands..")" or "")

				for i,cmd in pairs(event.commands) do
					local cmdF = cmdTemplate:Clone()
					local cmdTextBox = cmdF.TextBox
					ViewportTextBox.convert(cmdTextBox)
					cmdTextBox.Text = cmd[1]
					cmdF.Visible = true
					table.insert(shade1,cmdF)
					table.insert(shade2,cmdF.Delete)
					table.insert(shade2,cmdF.Settings)

					cmdTextBox.FocusLost:Connect(function()
						event.commands[i] = {cmdTextBox.Text,cmd[2],cmd[3]}
						if onEdited then onEdited() end
					end)

					cmdF.Settings.MouseButton1Click:Connect(function()
						openSettingsEditor(event,cmd)
					end)

					cmdF.Delete.MouseButton1Click:Connect(function()
						table.remove(event.commands,i)
						refreshCommands()
						resizeList()

						if currentlyEditingCmd == cmd then
							settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						end
						if onEdited then onEdited() end
					end)

					cmdF.Parent = eventF.Cmds.Holder
				end

				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			end

			local newBox = eventF.Cmds.Add.TextBox
			ViewportTextBox.convert(newBox)
			newBox.FocusLost:Connect(function(enter)
				if enter then
					event.commands[#event.commands+1] = {newBox.Text,defaultSettings(event),0}
					newBox.Text = ""

					refreshCommands()
					resizeList()
					if onEdited then onEdited() end
				end
			end)

			--eventF:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeList)

			eventF.Parent = eventListHolder

			refreshCommands()
		end

		resizeList()
	end

	local function saveData()
		local result = {}
		for i,v in pairs(events) do
			result[i] = v.commands
		end
		return HttpService:JSONEncode(result)
	end

	local function loadData(str)
		local data = HttpService:JSONDecode(str)
		for i,v in pairs(data) do
			if events[i] then
				events[i].commands = v
			end
		end
	end

	local function addCmd(event,data)
		table.insert(events[event].commands,data)
	end

	local function setOnEdited(f)
		if type(f) == "function" then
			onEdited = f
		end
	end

	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-175,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	return {
		RegisterEvent = registerEvent,
		FireEvent = fireEvent,
		Refresh = refreshList,
		SaveData = saveData,
		LoadData = loadData,
		AddCmd = addCmd,
		Frame = main,
		SetOnEdited = setOnEdited
	}
end)()

reference = (function()
	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="Main",Position=UDim2.new(0.5,-250,0,-500),Size=UDim2.new(0,500,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Size=UDim2.new(1,0,0.94999998807907,0),Text="Reference",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,300),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,1313),Name="List",Parent={6},ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,0),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",VerticalScrollBarInset=2,ZIndex=10,}},
		{8,"UIListLayout",{Parent={7},SortOrder=2,}},
		{9,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,429),ZIndex=10,}},
		{10,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={9},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Special Player Cases",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={9},Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-8,0,20),Text="These keywords can be used to quickly select groups of players in commands:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={9},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{13,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Cases",Parent={9},Position=UDim2.new(0,8,0,55),Size=UDim2.new(1,-16,0,342),ZIndex=10,}},
		{14,"UIListLayout",{Parent={13},SortOrder=2,}},
		{15,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={15},Size=UDim2.new(1,0,1,0),Text="all",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={15},Position=UDim2.new(0,15,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{18,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-3,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{19,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={18},Size=UDim2.new(1,0,1,0),Text="others",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={18},Position=UDim2.new(0,37,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone except you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{21,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-2,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{22,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={21},Size=UDim2.new(1,0,1,0),Text="me",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{23,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={21},Position=UDim2.new(0,19,0,0),Size=UDim2.new(1,0,1,0),Text="- includes your player only",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{24,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{25,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={24},Size=UDim2.new(1,0,1,0),Text="#[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{26,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={24},Position=UDim2.new(0,59,0,0),Size=UDim2.new(1,0,1,0),Text="- gets a specified amount of random players",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{27,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{28,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={27},Size=UDim2.new(1,0,1,0),Text="random",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{29,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={27},Position=UDim2.new(0,44,0,0),Size=UDim2.new(1,0,1,0),Text="- affects a random player",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={30},Size=UDim2.new(1,0,1,0),Text="%[team name]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={30},Position=UDim2.new(0,78,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone on a given team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{34,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={33},Size=UDim2.new(1,0,1,0),Text="allies / team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{35,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={33},Position=UDim2.new(0,63,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{37,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={36},Size=UDim2.new(1,0,1,0),Text="enemies / nonteam",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={36},Position=UDim2.new(0,101,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are not on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{39,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={39},Size=UDim2.new(1,0,1,0),Text="friends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{41,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={39},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{42,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={42},Size=UDim2.new(1,0,1,0),Text="nonfriends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{44,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={42},Position=UDim2.new(0,61,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is not friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{46,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={45},Size=UDim2.new(1,0,1,0),Text="guests",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{47,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={45},Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,0,1,0),Text="- guest players (obsolete)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{48,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{49,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={48},Size=UDim2.new(1,0,1,0),Text="bacons",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{50,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={48},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone with the \"bacon\" or pal hair",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{51,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={51},Size=UDim2.new(1,0,1,0),Text="age[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{53,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={51},Position=UDim2.new(0,71,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone below or at the given age",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={54},Size=UDim2.new(1,0,1,0),Text="rad[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={54},Position=UDim2.new(0,70,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone within the given radius",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{58,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={57},Size=UDim2.new(1,0,1,0),Text="nearest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{59,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={57},Position=UDim2.new(0,43,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the closest player to you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{61,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={60},Size=UDim2.new(1,0,1,0),Text="farthest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{62,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={60},Position=UDim2.new(0,46,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the farthest player from you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{63,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{64,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={63},Size=UDim2.new(1,0,1,0),Text="group[ID]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{65,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={63},Position=UDim2.new(0,55,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are in a certain group",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{66,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={66},Size=UDim2.new(1,0,1,0),Text="alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{68,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={66},Position=UDim2.new(0,27,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{69,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{70,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={69},Size=UDim2.new(1,0,1,0),Text="dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{71,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={69},Position=UDim2.new(0,29,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{72,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{73,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={72},Size=UDim2.new(1,0,1,0),Text="@username",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{74,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={72},Position=UDim2.new(0,66,0,0),Size=UDim2.new(1,0,1,0),Text="- searches for players by username only (ignores displaynames)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{75,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,180),ZIndex=10,}},
		{76,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={75},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Various Operators",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{77,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={75},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{78,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,16),Text="Use commas to separate multiple expressions:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{79,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,75),Size=UDim2.new(1,-8,0,16),Text="Use - to exclude, and + to include players in your expression:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{80,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,91),Size=UDim2.new(1,-8,0,16),Text=";locate %blue-friends (gets players in blue team who aren't your friends)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,46),Size=UDim2.new(1,-8,0,16),Text=";locate noob,noob2,bob",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{82,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,120),Size=UDim2.new(1,-8,0,16),Text="Put ! before a command to run it with the last arguments it was ran with:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{83,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,136),Size=UDim2.new(1,-8,0,32),Text="After running ;offset 0 100 0,  you can run !offset anytime to repeat that command with the same arguments that were used to run it last time",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,154),ZIndex=10,}},
		{85,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={84},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Command Looping",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{86,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="Form: [How many times it loops]^[delay (optional)]^[command]",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{87,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={84},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{88,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,50),Size=UDim2.new(1,-8,0,20),Text="Use the 'breakloops' command to stop all running loops.",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{89,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,80),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{90,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,98),Size=UDim2.new(1,-8,0,42),Text=";5^btools - gives you 5 sets of btools\n;10^3^drophats - drops your hats every 3 seconds 10 times\n;inf^0.1^animspeed 100 - infinitely loops your animation speed to 100",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{91,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,120),ZIndex=10,}},
		{92,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Execute Multiple Commands at Once",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{93,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="You can execute multiple commands at once using \"\\\"",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{94,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={91},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{96,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={91},Position=UDim2.new(0,8,0,78),Size=UDim2.new(1,-8,0,32),Text=";drophats\\respawn - drops your hats and respawns you\n;enable inventory\\enable playerlist\\refresh - enables those coregui items and refreshes you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{97,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{98,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={97},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Browse Command History",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{99,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={97},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the up and down arrow keys to browse recently used commands",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{100,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={97},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{101,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{102,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={101},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Autocomplete in the Command Bar",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{103,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={101},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the tab key to insert the top suggested command into the command bar.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{104,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={101},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{105,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,175),ZIndex=10,}},
		{106,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={105},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Using Event Binds",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{107,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="Use event binds to set up commands that get executed when certain events happen. You can edit the conditions for an event command to run (such as which player triggers it).",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{108,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={105},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{109,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,70),Size=UDim2.new(1,-8,0,48),Text="Some events may send arguments; you can use them in your event command by using $ followed by the argument number ($1, $2, etc). You can find out the order and types of these arguments by looking at the settings of the event command.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{110,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={105},Position=UDim2.new(0,8,0,130),Size=UDim2.new(1,-8,0,16),Text="Example:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{111,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,148),Size=UDim2.new(1,-8,0,16),Text="Setting up 'goto $1' on the OnChatted event will teleport you to any player that chats.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{112,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,105),ZIndex=10,}},
		{113,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={112},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Get Further Help",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{114,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={112},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="You can join the Discord server to get support with IY,  and read up on more documentation such as the Plugin API.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{115,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={112},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),Visible=false,ZIndex=10,}},
		{116,"TextButton",{BackgroundColor3=Color3.new(0.48627451062202,0.61960786581039,0.85098040103912),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Font=4,Name="InviteButton",Parent={112},Position=UDim2.new(0,5,0,75),Size=UDim2.new(1,-10,0,25),Text="Copy Discord Invite Link (https://discord.gg/78ZuWSq)",TextColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),TextSize=16,ZIndex=10,}},
	})
	for i,v in pairs(main.Content.List:GetDescendants()) do
		if v:IsA("TextLabel") then
			table.insert(text1,v)
		end
	end
	table.insert(scroll,main.Content.List)
	table.insert(shade1,main.Content)
	table.insert(shade2,main.TopBar)
	main.Name = randomString()
	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	local inviteButton = main:FindFirstChild("InviteButton",true)
	local lastPress = nil
	inviteButton.MouseButton1Click:Connect(function()
		if everyClipboard then
			toClipboard("https://discord.gg/78ZuWSq")
			inviteButton.Text = "Copied"
		else
			inviteButton.Text = "No Clipboard Function, type out the link"
		end
		local pressTime = tick()
		lastPress = pressTime
		wait(2)
		if lastPress ~= pressTime then return end
		inviteButton.Text = "Copy Discord Invite Link (https://discord.gg/78ZuWSq)"
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	ReferenceButton.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0.5,-150), "InOut", "Quart", 0.5, true, nil)
	end)
end)()

currentShade1 = Color3.fromRGB(36, 36, 37)
currentShade2 = Color3.fromRGB(46, 46, 47)
currentShade3 = Color3.fromRGB(78, 78, 79)
currentText1 = Color3.new(1, 1, 1)
currentText2 = Color3.new(0, 0, 0)
currentScroll = Color3.fromRGB(78,78,79)

defaultGuiScale = IsOnMobile and 0.9 or 1
local autoHideDelay = 1.5
local prefix = ';' -- Fixed internal shortcut; commands entered in Command Bar need no prefix.
local waypointHoverPositions = {}
local waypointBackTPEnabled = true
favoriteCommands = {}
defaultsettings = {
	autoHideDelay = 1.5;
	StayOpen = false;
	waypointBackTPEnabled = true;
	guiScale = defaultGuiScale;
	espTransparency = 0.3;
	keepIY = true;
	logsEnabled = false;
	jLogsEnabled = false;
	aliases = {};
	binds = {};
	WayPoints = {};
	PluginsTable = {};
	waypointHoverPositions = waypointHoverPositions;
	favoriteCommands = {};
	currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
	currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
	currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
	currentText1 = {currentText1.R,currentText1.G,currentText1.B};
	currentText2 = {currentText2.R,currentText2.G,currentText2.B};
	currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
	eventBinds = eventEditor.SaveData()
}

defaults = HttpService:JSONEncode(defaultsettings)
nosaves = false
useFactorySettings = function()
	autoHideDelay = 1.5
	prefix = ';'
	StayOpen = false
	waypointBackTPEnabled = true
	guiScale = defaultGuiScale
	KeepInfYield = true
	espTransparency = 0.3
	logsEnabled = false
	jLogsEnabled = false
	logsWebhook = nil
	aliases = {}
	binds = {}
	WayPoints = {}
	PluginsTable = {}
	favoriteCommands = {}
end

function createPopup(title, text)
	local Popup = Instance.new("Frame")
	local background = Instance.new("Frame")
	local Directions = Instance.new("TextLabel")
	local shadow = Instance.new("Frame")
	local PopupText = Instance.new("TextLabel")
	local Exit = Instance.new("TextButton")
	local ExitImage = Instance.new("ImageLabel")

	Popup.Name = randomString()
	Popup.Parent = ScaledHolder
	Popup.Active = true
	Popup.BackgroundTransparency = 1
	Popup.Position = UDim2.new(0.5, -180, 0, -500)
	Popup.Size = UDim2.new(0, 360, 0, 20)
	Popup.ZIndex = 10

	background.Name = "background"
	background.Parent = Popup
	background.Active = true
	background.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
	background.BorderSizePixel = 0
	background.Position = UDim2.new(0, 0, 0, 20)
	background.Size = UDim2.new(0, 360, 0, 205)
	background.ZIndex = 10

	Directions.Name = "Directions"
	Directions.Parent = background
	Directions.BackgroundTransparency = 1
	Directions.BorderSizePixel = 0
	Directions.Position = UDim2.new(0, 10, 0, 10)
	Directions.Size = UDim2.new(0, 340, 0, 185)
	Directions.Font = Enum.Font.SourceSans
	Directions.TextSize = 14
	Directions.Text = text
	Directions.TextColor3 = Color3.new(1, 1, 1)
	Directions.TextWrapped = true
	Directions.TextXAlignment = Enum.TextXAlignment.Left
	Directions.TextYAlignment = Enum.TextYAlignment.Top
	Directions.ZIndex = 10

	shadow.Name = "shadow"
	shadow.Parent = Popup
	shadow.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	shadow.BorderSizePixel = 0
	shadow.Size = UDim2.new(0, 360, 0, 20)
	shadow.ZIndex = 10

	PopupText.Name = "PopupText"
	PopupText.Parent = shadow
	PopupText.BackgroundTransparency = 1
	PopupText.Size = UDim2.new(1, 0, 0.95, 0)
	PopupText.ZIndex = 10
	PopupText.Font = Enum.Font.SourceSans
	PopupText.TextSize = 14
	PopupText.Text = title
	PopupText.TextColor3 = Color3.new(1, 1, 1)
	PopupText.TextWrapped = true

	Exit.Name = "Exit"
	Exit.Parent = shadow
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(1, -20, 0, 0)
	Exit.Size = UDim2.new(0, 20, 0, 20)
	Exit.Text = ""
	Exit.ZIndex = 10

	ExitImage.Parent = Exit
	ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
	ExitImage.BackgroundTransparency = 1
	ExitImage.Position = UDim2.new(0, 5, 0, 5)
	ExitImage.Size = UDim2.new(0, 10, 0, 10)
	ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
	ExitImage.ZIndex = 10

	Popup:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

	Exit.MouseButton1Click:Connect(function()
		Popup:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
		task.wait(0.6)
		Popup:Destroy()
	end)
end

local loadedEventData = nil
local jsonAttempts = 0
local FAVORITES_BACKUP_FILE = "IY_FE_Favorites.iy"

local function sanitizeFavoriteNames(list)
    local cleaned, seen = {}, {}
    if type(list) == "table" then
        for _, name in ipairs(list) do
            if type(name) == "string" and name ~= "" and not seen[name] then
                seen[name] = true
                table.insert(cleaned, name)
            end
        end
    end
    return cleaned
end

local function readFavoriteBackup()
    if not readfileExploit() then return nil end
    local ok, raw = readfile(FAVORITES_BACKUP_FILE, true)
    if not ok or type(raw) ~= "string" or raw == "" then return nil end
    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not decodedOk or type(decoded) ~= "table" then return nil end
    return sanitizeFavoriteNames(decoded)
end

local function writeFavoriteBackup()
    if not writefileExploit() then return end
    pcall(function()
        writefile(FAVORITES_BACKUP_FILE, HttpService:JSONEncode(sanitizeFavoriteNames(favoriteCommands)), true)
    end)
end

function saves()
	if writefileExploit() and readfileExploit() and jsonAttempts < 10 then
		local readSuccess, out = readfile("IY_FE.iy", true)
		if readSuccess then
			if out ~= nil and tostring(out):gsub("%s", "") ~= "" then
				local success, response = pcall(function()
					local json = HttpService:JSONDecode(out)
					local loadedFavorites = nil
					if vtype(json.favoriteCommands, "table") then
						loadedFavorites = sanitizeFavoriteNames(json.favoriteCommands)
					end
					local backupFavorites = readFavoriteBackup()
					-- Prefer a populated main config; if an older build removed this field
					-- or rewrote it empty, recover the separate favorites backup.
					if (not loadedFavorites or #loadedFavorites == 0) and backupFavorites and #backupFavorites > 0 then
						loadedFavorites = backupFavorites
					end
					favoriteCommands = loadedFavorites or {}
					if vtype(json.autoHideDelay, "number") and json.autoHideDelay >= 0.1 and json.autoHideDelay <= 10 then
						autoHideDelay = math.floor(json.autoHideDelay * 10 + 0.5) / 10
					else
						autoHideDelay = 1.5
					end
					if vtype(json.StayOpen, "boolean") then StayOpen = json.StayOpen else StayOpen = false end
					if vtype(json.waypointBackTPEnabled, "boolean") then waypointBackTPEnabled = json.waypointBackTPEnabled else waypointBackTPEnabled = true end
					if vtype(json.guiScale, "number") then guiScale = json.guiScale else guiScale = defaultGuiScale end
					if vtype(json.keepIY, "boolean") then KeepInfYield = json.keepIY else KeepInfYield = true end
					if vtype(json.espTransparency, "number") then espTransparency = json.espTransparency else espTransparency = 0.3 end
					if vtype(json.logsEnabled, "boolean") then logsEnabled = json.logsEnabled else logsEnabled = false end
					if vtype(json.jLogsEnabled, "boolean") then jLogsEnabled = json.jLogsEnabled else jLogsEnabled = false end
					if vtype(json.logsWebhook, "string") then logsWebhook = json.logsWebhook else logsWebhook = nil end
					if vtype(json.aliases, "table") then aliases = json.aliases else aliases = {} end
					if vtype(json.binds, "table") then binds = json.binds else binds = {} end
					if vtype(json.spawnCmds, "table") then spawnCmds = json.spawnCmds end
					if vtype(json.WayPoints, "table") then AllWaypoints = json.WayPoints else WayPoints = {} AllWaypoints = {} end
					if vtype(json.waypointHoverPositions, "table") then
						local validWaypointHoverPositions = {}
						for waypointKey, savedPosition in pairs(json.waypointHoverPositions) do
							if type(waypointKey) == "string" and type(savedPosition) == "table" then
								local savedX, savedY = tonumber(savedPosition.x), tonumber(savedPosition.y)
								if savedX and savedY and math.abs(savedX) < 100000 and math.abs(savedY) < 100000 then
									validWaypointHoverPositions[string.lower(waypointKey)] = {x = math.floor(savedX), y = math.floor(savedY)}
								end
							end
						end
						waypointHoverPositions = validWaypointHoverPositions
					else
						waypointHoverPositions = {}
					end
					if vtype(json.PluginsTable, "table") then PluginsTable = json.PluginsTable else PluginsTable = {} end
					if vtype(json.currentShade1, "table") then currentShade1 = Color3.new(json.currentShade1[1],json.currentShade1[2],json.currentShade1[3]) end
					if vtype(json.currentShade2, "table") then currentShade2 = Color3.new(json.currentShade2[1],json.currentShade2[2],json.currentShade2[3]) end
					if vtype(json.currentShade3, "table") then currentShade3 = Color3.new(json.currentShade3[1],json.currentShade3[2],json.currentShade3[3]) end
					if vtype(json.currentText1, "table") then currentText1 = Color3.new(json.currentText1[1],json.currentText1[2],json.currentText1[3]) end
					if vtype(json.currentText2, "table") then currentText2 = Color3.new(json.currentText2[1],json.currentText2[2],json.currentText2[3]) end
					if vtype(json.currentScroll, "table") then currentScroll = Color3.new(json.currentScroll[1],json.currentScroll[2],json.currentScroll[3]) end
					if vtype(json.eventBinds, "string") then loadedEventData = json.eventBinds end
				end)
				if not success then
					jsonAttempts = jsonAttempts + 1
					warn("Save Json Error:", response)
					warn("Overwriting Save File")
					writefile("IY_FE.iy", defaults, true)
					wait()
					saves()
				end
			else
				writefile("IY_FE.iy", defaults, true)
				wait()
				local dReadSuccess, dOut = readfile("IY_FE.iy", true)
				if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
					saves()
				else
					nosaves = true
					useFactorySettings()
					createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
				end
			end
		else
			writefile("IY_FE.iy", defaults, true)
			wait()
			local dReadSuccess, dOut = readfile("IY_FE.iy", true)
			if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
				saves()
			else
				nosaves = true
				useFactorySettings()
				createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
			end
		end
	else
		if jsonAttempts >= 10 then
			nosaves = true
			useFactorySettings()
			createPopup("File Error", "Sorry, we have attempted to parse your save file, but it is unreadable!\n\nInfinite Yield is now using factory settings until your exploit's file system works.\n\nYour save file has not been deleted.")
		else
			nosaves = true
			useFactorySettings()
		end
	end
end

saves()
writeFavoriteBackup()

-- Start in hideiy mode on mobile regardless of the previously saved Keep Menu Open state.
if IsOnMobile then StayOpen = false end

function updatesaves()
	if nosaves == false and writefileExploit() then
		local update = {
			autoHideDelay = autoHideDelay;
			StayOpen = StayOpen;
			waypointBackTPEnabled = waypointBackTPEnabled;
			guiScale = guiScale;
			keepIY = KeepInfYield;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			waypointHoverPositions = waypointHoverPositions;
			favoriteCommands = favoriteCommands or {};
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("IY_FE.iy", HttpService:JSONEncode(update))
		writeFavoriteBackup()
	end
end

eventEditor.SetOnEdited(updatesaves)

pWayPoints = {}
WayPoints = {}

if #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

if type(binds) ~= "table" then binds = {} end

if type(PluginsTable) == "table" then
	for i = #PluginsTable, 1, -1 do
		if string.sub(PluginsTable[i], -3) ~= ".iy" then
			table.remove(PluginsTable, i)
		end
	end
end

function Time()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and 'PM' or 'AM'
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and '0' .. HOUR or HOUR
	MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
	SECOND = SECOND < 10 and '0' .. SECOND or SECOND
	return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

local SettingsOpen = false
local isHidden = IsOnMobile
local cmdbarVisibilityBeforeSettings = nil
local cmdbarTextTransparencyBeforeSettings = nil
local cmdbarFadeToken = 0
local settingsGeometryToken = 0

-- Keep the original Infinite Yield backdrop behavior.
-- Dark remains the command-list backdrop; the opaque Settings panel covers it while open.
local holderBackgroundTransparencyBeforeSettings = Holder.BackgroundTransparency
local function setSettingsBackdrop(open)
    Dark.Visible = true
    Holder.BackgroundTransparency = holderBackgroundTransparencyBeforeSettings
end

-- Fade the command input out while settings move into its space; restore its prior state on close.
local function setSettingsOpenState(open)
    cmdbarFadeToken += 1
    local thisFadeToken = cmdbarFadeToken

    if open then
        -- Fill both the former command-bar row and command-list area with one Settings panel.
        settingsGeometryToken += 1
        Settings.BackgroundTransparency = 0
        Settings.Size = UDim2.new(0, 250, 0, 200)
        setSettingsBackdrop(true)
        CMDsF.Visible = false
        if not SettingsOpen then
            cmdbarVisibilityBeforeSettings = Cmdbar.Visible
            cmdbarTextTransparencyBeforeSettings = Cmdbar.TextTransparency
        end
        SettingsOpen = true
        if CmdbarView then CmdbarView.Visible = false end
        if Cmdbar.Visible then
            TweenService:Create(Cmdbar, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
            task.delay(0.12, function()
                if thisFadeToken ~= cmdbarFadeToken or not SettingsOpen then return end
                Cmdbar.Visible = false
                if cmdbarTextTransparencyBeforeSettings ~= nil then
                    Cmdbar.TextTransparency = cmdbarTextTransparencyBeforeSettings
                end
            end)
        else
            Cmdbar.Visible = false
        end
    else
        SettingsOpen = false
        settingsGeometryToken += 1
        local closeGeometryToken = settingsGeometryToken
        task.delay(0.52, function()
            if closeGeometryToken == settingsGeometryToken and not SettingsOpen then
                Settings.Size = UDim2.new(0, 250, 0, 175)
            end
        end)
        setSettingsBackdrop(false)
        CMDsF.Visible = true
        if cmdbarVisibilityBeforeSettings ~= nil then
            local shouldRestoreCmdbar = cmdbarVisibilityBeforeSettings
            local restoreTextTransparency = cmdbarTextTransparencyBeforeSettings
            cmdbarVisibilityBeforeSettings = nil
            cmdbarTextTransparencyBeforeSettings = nil

            if shouldRestoreCmdbar then
                if CmdbarView then CmdbarView.Visible = true end
                Cmdbar.TextTransparency = 1
                Cmdbar.Visible = true
                TweenService:Create(Cmdbar, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextTransparency = restoreTextTransparency or 0
                }):Play()
            else
                if CmdbarView then CmdbarView.Visible = false end
                Cmdbar.Visible = false
                if restoreTextTransparency ~= nil then
                    Cmdbar.TextTransparency = restoreTextTransparency
                end
            end
        end
    end
end

local function updateStayOpenVisual()
	local enabled = StayOpen == true
	On.BackgroundTransparency = enabled and 0 or 1
	On.Text = enabled and "✓" or ""
	On.TextColor3 = Color3.new(1, 1, 1)
	On.Font = Enum.Font.SourceSansBold
	On.TextSize = 13
end

updateStayOpenVisual()

if logsEnabled then
	Toggle.Text = 'Enabled'
else
	Toggle.Text = 'Disabled'
end

if jLogsEnabled then
	Toggle_2.Text = 'Enabled'
else
	Toggle_2.Text = 'Disabled'
end

AutoHideDelayBox.Text = string.format("%.1f", autoHideDelay)
AutoHideDelayBox.FocusLost:Connect(function()
	local value = tonumber(AutoHideDelayBox.Text)
	if value == nil then
		AutoHideDelayBox.Text = string.format("%.1f", autoHideDelay)
		return
	end
	value = math.clamp(value, 0.1, 10)
	autoHideDelay = math.floor(value * 10 + 0.5) / 10
	AutoHideDelayBox.Text = string.format("%.1f", autoHideDelay)
	updatesaves()
end)

local holderHideToken = 0

local function scheduleHolderAutoHide(delaySeconds)
	holderHideToken += 1
	local thisToken = holderHideToken
	task.delay(delaySeconds or autoHideDelay or 1.5, function()
		if thisToken ~= holderHideToken then return end
		if StayOpen == true or SettingsOpen == true or Cmdbar:IsFocused() then return end
		minimizeHolder()
	end)
end

function maximizeHolder()
	holderHideToken += 1
	Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -220), "InOut", "Quart", 0.2, true, nil)
end

minimizeNum = IsOnMobile and 0 or -20
function minimizeHolder()
	holderHideToken += 1
	if StayOpen == true or SettingsOpen == true then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -220), "InOut", "Quart", 0.2, true, nil)
		return
	end
	Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, minimizeNum), "InOut", "Quart", 0.5, true, nil)
end

function cmdbarHolder()
	if StayOpen == true or SettingsOpen == true then
		maximizeHolder()
	else
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -45), "InOut", "Quart", 0.5, true, nil)
	end
end

pinNotification = nil
local notifyCount = 0
function notify(text,text2,length)
	task.spawn(function()
		local LnotifyCount = notifyCount+1
		local notificationPinned = false
		notifyCount = notifyCount+1
		if pinNotification then pinNotification:Disconnect() end
		pinNotification = PinButton.MouseButton1Click:Connect(function()
			task.spawn(function()
				pinNotification:Disconnect()
				notificationPinned = true
				Title_2.BackgroundTransparency = 1
				wait(0.5)
				Title_2.BackgroundTransparency = 0
			end)
		end)
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.6)
		local closepressed = false
		if text2 then
			Title_2.Text = text
			Text_2.Text = text2
		else
			Title_2.Text = 'Notification'
			Text_2.Text = text
		end
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, -100), "InOut", "Quart", 0.5, true, nil)
		CloseButton.MouseButton1Click:Connect(function()
			Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			closepressed = true
			pinNotification:Disconnect()
		end)
		if length and isNumber(length) then
			wait(length)
		else
			wait(10)
		end
		if LnotifyCount == notifyCount then
			if closepressed == false and notificationPinned == false then
				pinNotification:Disconnect()
				Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			end
			notifyCount = 0
		end
	end)
end

local lastMessage = nil
local lastLabel = nil
local dupeCount = 1
function CreateLabel(Name, Text)
	if lastMessage == Name..Text then
		dupeCount = dupeCount+1
		lastLabel.Text = Time()..' - ['..Name..']: '..Text..' (x'..dupeCount..')'
	else
		if dupeCount > 1 then dupeCount = 1 end
		if #scroll_2:GetChildren() >= 2546 then
			scroll_2:ClearAllChildren()
		end
		local alls = 0
		for i,v in pairs(scroll_2:GetChildren()) do
			if v then
				alls = v.Size.Y.Offset + alls
			end
			if not v then
				alls = 0
			end
		end
		local tl = Instance.new('TextLabel')
		lastMessage = Name..Text
		lastLabel = tl
		tl.Name = Name
		tl.Parent = scroll_2
		tl.ZIndex = 10
		tl.RichText = true
		tl.Text = Time().." - ["..Name.."]: "..Text
		tl.Text = tl.ContentText
		tl.Size = UDim2.new(0,322,0,84)
		tl.BackgroundTransparency = 1
		tl.BorderSizePixel = 0
		tl.Font = "SourceSans"
		tl.Position = UDim2.new(-1,0,0,alls)
		tl.TextTransparency = 1
		tl.TextScaled = false
		tl.TextSize = 14
		tl.TextWrapped = true
		tl.TextXAlignment = "Left"
		tl.TextYAlignment = "Top"
		tl.TextColor3 = currentText1
		tl.Size = UDim2.new(0,322,0,tl.TextBounds.Y)
		table.insert(text1,tl)
		scroll_2.CanvasSize = UDim2.new(0,0,0,alls+tl.TextBounds.Y)
		scroll_2.CanvasPosition = Vector2.new(0,scroll_2.CanvasPosition.Y+tl.TextBounds.Y)
		tl:TweenPosition(UDim2.new(0,3,0,alls), 'In', 'Quint', 0.5)
		TweenService:Create(tl, TweenInfo.new(1.25, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
	end
end

function CreateJoinLabel(player, userId)
    if #scroll_3:GetChildren() >= 2546 then
        scroll_3:ClearAllChildren()
    end
    local infoFrame = Instance.new("Frame")
    local info1 = Instance.new("TextLabel")
    local info2 = Instance.new("TextLabel")
    local ImageLabel_3 = Instance.new("ImageLabel")
    infoFrame.Name = randomString()
    infoFrame.Parent = scroll_3
    infoFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    infoFrame.BackgroundTransparency = 1
    infoFrame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
    infoFrame.Size = UDim2.new(1, 0, 0, 50)
    info1.Name = randomString()
    info1.Parent = infoFrame
    info1.BackgroundTransparency = 1
    info1.BorderSizePixel = 0
    info1.Position = UDim2.new(0, 45, 0, 0)
    info1.Size = UDim2.new(0, 135, 1, 0)
    info1.ZIndex = 10
    info1.Font = Enum.Font.SourceSans
    info1.FontSize = Enum.FontSize.Size14
    info1.Text = "Username: " .. player.Name .. "\nJoined Server: " .. Time()
    info1.TextColor3 = Color3.new(1, 1, 1)
    info1.TextWrapped = true
    info1.TextXAlignment = Enum.TextXAlignment.Left
    info2.Name = randomString()
    info2.Parent = infoFrame
    info2.BackgroundTransparency = 1
    info2.BorderSizePixel = 0
    info2.Position = UDim2.new(0, 185, 0, 0)
    info2.Size = UDim2.new(0, 140, 1, -5)
    info2.ZIndex = 10
    info2.Font = Enum.Font.SourceSans
    info2.FontSize = Enum.FontSize.Size14
    info2.Text = "User ID: " .. userId .. "\nAccount Age: " .. player.AccountAge .. "\nJoined Roblox: Loading..."
    info2.TextColor3 = Color3.new(1, 1, 1)
    info2.TextWrapped = true
    info2.TextXAlignment = Enum.TextXAlignment.Left
    info2.TextYAlignment = Enum.TextYAlignment.Center
    ImageLabel_3.Parent = infoFrame
    ImageLabel_3.BackgroundTransparency = 1
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Size = UDim2.new(0, 45, 1, 0)
    ImageLabel_3.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
    scroll_3.CanvasSize = UDim2.new(0, 0, 0, listlayout.AbsoluteContentSize.Y)
    scroll_3.CanvasPosition = Vector2.new(0, scroll_2.CanvasPosition.Y + infoFrame.AbsoluteSize.Y)
    local date = os.date("!%Y-%m-%d", os.time() - (player.AccountAge * 86400))
    local splitDates = string.split(date, "-")
    info2.Text = string.gsub(info2.Text, "Loading...", splitDates[2] .. "/" .. splitDates[3] .. "/" .. splitDates[1])
end

IY_RELOAD_INSTANCE_STATE.TrackConnection(IYMouse.KeyDown:Connect(function(Key)
	if (Key==prefix) then
		RunService.RenderStepped:Wait()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end
end))

Holder.MouseEnter:Connect(function()
	maximizeHolder()
end)

Holder.MouseLeave:Connect(function()
	if not Cmdbar:IsFocused() and not StayOpen and not SettingsOpen then
		scheduleHolderAutoHide(autoHideDelay)
	end
end)

local function applyCommandPaletteColors()
	local commandBarColor = currentShade2 or Color3.fromRGB(46, 46, 47)
	local commandListColor = currentShade1 or (Title and Title.BackgroundColor3) or Color3.fromRGB(36, 36, 37)
	local headerColor = commandBarColor:Lerp(Color3.fromRGB(112, 112, 116), 0.16)
	if CmdbarView and CmdbarView.Parent then
		CmdbarView.BackgroundColor3 = commandBarColor
	end
	if CMDsF and CMDsF.Parent then
		CMDsF.BackgroundColor3 = commandListColor
	end
	if FavSectionHeader and FavSectionHeader.Parent then
		FavSectionHeader.BackgroundColor3 = headerColor
	end
	if AllCommandsHeader and AllCommandsHeader.Parent then
		AllCommandsHeader.BackgroundColor3 = headerColor
	end
end

function updateColors(color,ctype)
	if ctype == shade1 then
		for i,v in pairs(shade1) do
			v.BackgroundColor3 = color
		end
		currentShade1 = color
		applyCommandPaletteColors()
	elseif ctype == shade2 then
		for i,v in pairs(shade2) do
			v.BackgroundColor3 = color
		end
		currentShade2 = color
		applyCommandPaletteColors()
	elseif ctype == shade3 then
		for i,v in pairs(shade3) do
			v.BackgroundColor3 = color
		end
		for _, waypointFrame in ipairs(waypointHoverFrames) do
			if waypointFrame and waypointFrame.Parent then
				waypointFrame.BorderColor3 = color
			end
		end
		currentShade3 = color
	elseif ctype == text1 then
		for i,v in pairs(text1) do
			v.TextColor3 = color
			if v:IsA("TextBox") then
				v.PlaceholderColor3 = color	
			end
		end
		currentText1 = color
	elseif ctype == text2 then
		for i,v in pairs(text2) do
			v.TextColor3 = color
		end
		currentText2 = color
	elseif ctype == scroll then
		for i,v in pairs(scroll) do
			v.ScrollBarImageColor3 = color
		end
		currentScroll = color
	end
end


SettingsButton.MouseButton1Click:Connect(function()
	if SettingsOpen == false then
		-- Always show the settings from the top so no partially clipped row remains at the bottom.
		SettingsHolder.CanvasPosition = Vector2.new(0, 0)
		setSettingsOpenState(true)
		setSettingsBackdrop(true)
		Settings:TweenPosition(UDim2.new(0, 0, 0, 20), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	else setSettingsOpenState(false)
		setSettingsBackdrop(false)
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.5, true, nil)
	end
	maximizeHolder()
end)

local lastStayOpenToggle = 0
local function toggleStayOpen()
	if isHidden then return end
	-- Prevent a single mobile tap from being processed twice by overlapping controls.
	local now = os.clock()
	if now - lastStayOpenToggle < 0.15 then return end
	lastStayOpenToggle = now
	StayOpen = not StayOpen
	updateStayOpenVisual()
	if StayOpen then
		maximizeHolder()
	else
		scheduleHolderAutoHide(autoHideDelay)
	end
	updatesaves()
end

StayOpenButton.MouseButton1Click:Connect(toggleStayOpen)
Button.MouseButton1Click:Connect(toggleStayOpen)

Clear.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_2:GetChildren()) do
		child:Destroy()
	end
	scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Clear_2.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_3:GetChildren()) do
		child:Destroy()
	end
	scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Toggle.MouseButton1Down:Connect(function()
	if logsEnabled then
		logsEnabled = false
		Toggle.Text = 'Disabled'
		updatesaves()
	else
		logsEnabled = true
		Toggle.Text = 'Enabled'
		updatesaves()
	end
end)

Toggle_2.MouseButton1Down:Connect(function()
	if jLogsEnabled then
		jLogsEnabled = false
		Toggle_2.Text = 'Disabled'
		updatesaves()
	else
		jLogsEnabled = true
		Toggle_2.Text = 'Enabled'
		updatesaves()
	end
end)

selectChat.MouseButton1Down:Connect(function()
	join.Visible = false
	chat.Visible = true
	table.remove(shade3,table.find(shade3,selectChat))
	table.remove(shade2,table.find(shade2,selectJoin))
	table.insert(shade2,selectChat)
	table.insert(shade3,selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
end)

selectJoin.MouseButton1Down:Connect(function()
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3,table.find(shade3,selectJoin))
	table.remove(shade2,table.find(shade2,selectChat))
	table.insert(shade2,selectJoin)
	table.insert(shade3,selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
end)

if not writefileExploit() then
	notify("Saves", "Your exploit does not support read/write file. Your settings will not save.")
end

avatarcache = {}
function sendChatWebhook(player, message)
	if httprequest and vtype(logsWebhook, "string") then
		local id = player.UserId
		local avatar = avatarcache[id]
		if not avatar then
			local d = HttpService:JSONDecode(httprequest({
				Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. id .. "&size=420x420&format=Png&isCircular=false",
				Method = "GET"
			}).Body)["data"]
			avatar = d and d[1].state == "Completed" and d[1].imageUrl or "https://files.catbox.moe/i968v2.jpg"
			avatarcache[id] = avatar
		end
		local log = HttpService:JSONEncode({
			content = message,
			avatar_url = avatar,
			username = formatUsername(player),
			allowed_mentions = {parse = {}}
		})
		httprequest({
			Url = logsWebhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = log
		})
	end
end

ChatLog = function(player)
	player.Chatted:Connect(function(message)
		if logsEnabled == true then
			CreateLabel(player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

JoinLog = function(plr)
	if jLogsEnabled == true then
		CreateJoinLabel(plr,plr.UserId)
	end
end

CleanFileName = function(name)
	return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
end

SaveChatlogs.MouseButton1Down:Connect(function()
	if writefileExploit() then
		if #scroll_2:GetChildren() > 0 then
			notify("Loading",'Hold on a sec')
			local placeName = CleanFileName(MarketplaceService:GetProductInfo(PlaceId).Name)
			local writelogs = '-- Infinite Yield Chat logs for "'..placeName..'"\n'
			for _, child in pairs(scroll_2:GetChildren()) do
				writelogs = writelogs..'\n'..child.Text
			end
			local writelogsFile = tostring(writelogs)
			local fileext = 0
			local function nameFile()
				local file
				pcall(function() file = readfile(placeName..' Chat Logs ('..fileext..').txt') end)
				if file then
					fileext = fileext+1
					nameFile()
				else
					writefileCooldown(placeName..' Chat Logs ('..fileext..').txt', writelogsFile)
				end
			end
			nameFile()
			notify('Chat Logs','Saved chat logs to the workspace folder within your exploit folder.')
		end
	else
		notify('Chat Logs','Your exploit does not support write file. You cannot save chat logs.')
	end
end)

if isLegacyChat then
	for _, plr in pairs(Players:GetPlayers()) do
		ChatLog(plr)
	end
end

IY_RELOAD_INSTANCE_STATE.TrackConnection(Players.PlayerRemoving:Connect(function(player)
	if ESPenabled or CHMSenabled or COREGUI:FindFirstChild(player.Name..'_LC') then
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == player.Name..'_ESP' or v.Name == player.Name..'_LC' or v.Name == player.Name..'_CHMS' then
				v:Destroy()
			end
		end
	end
	if viewing ~= nil and player == viewing then
		workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
		viewing = nil
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		notify('Spectate','View turned off (player left)')
	end
	eventEditor.FireEvent("OnLeave", player.Name)
end))

Exit.MouseButton1Down:Connect(function()
	logs:TweenPosition(UDim2.new(0, 0, 1, 10), "InOut", "Quart", 0.3, true, nil)
end)

Hide.MouseButton1Down:Connect(function()
	if logs.Position ~= UDim2.new(0, 0, 1, -20) then
		logs:TweenPosition(UDim2.new(0, 0, 1, -20), "InOut", "Quart", 0.3, true, nil)
	else
		logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
	end
end)

EventBind.MouseButton1Click:Connect(function()
	eventEditor.Frame:TweenPosition(UDim2.new(0.5,-175,0.5,-101), "InOut", "Quart", 0.5, true, nil)
end)

Close.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
end)

Add.MouseButton1Click:Connect(function()
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, 260), "InOut", "Quart", 0.5, true, nil)
end)

Delete.MouseButton1Click:Connect(function()
	binds = {}
	refreshbinds()
	updatesaves()
	notify('Keybinds Updated','Removed all keybinds')
end)

local aliasPanelTransitionToken = 0
local aliasPanelState = "settings"
local aliasPanelHiddenPosition = UDim2.new(0, 0, 0, 200)
local aliasPanelShownPosition = UDim2.new(0, 0, 0, 0)

local function openAliasesPanel()
    aliasPanelTransitionToken += 1
    local token = aliasPanelTransitionToken
    aliasPanelState = "aliases"
    AliasAddDialog.Visible = false
    AliasClearConfirmFrame.Visible = false
    AliasAddDialog.Position = aliasPanelHiddenPosition
    AliasClearConfirmFrame.Position = aliasPanelHiddenPosition
    AliasesFrame.Visible = true
    AliasesFrame.Position = aliasPanelHiddenPosition
    AliasesFrame:TweenPosition(aliasPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
    task.delay(0.52, function()
        if token ~= aliasPanelTransitionToken or aliasPanelState ~= "aliases" then return end
        SettingsHolder.Visible = false
    end)
end

local function returnToAliasesPanel()
    aliasPanelTransitionToken += 1
    local token = aliasPanelTransitionToken
    aliasPanelState = "aliases"
    SettingsHolder.Visible = false
    AliasesFrame.Visible = true
    AliasesFrame.Position = aliasPanelHiddenPosition
    AliasesFrame:TweenPosition(aliasPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
    if AliasAddDialog.Visible then
        AliasAddDialog:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
    end
    if AliasClearConfirmFrame.Visible then
        AliasClearConfirmFrame:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
    end
    task.delay(0.52, function()
        if token ~= aliasPanelTransitionToken or aliasPanelState ~= "aliases" then return end
        AliasAddDialog.Visible = false
        AliasClearConfirmFrame.Visible = false
        AliasAddDialog.Position = aliasPanelHiddenPosition
        AliasClearConfirmFrame.Position = aliasPanelHiddenPosition
    end)
end

local function openAliasAddPanel()
    aliasPanelTransitionToken += 1
    local token = aliasPanelTransitionToken
    aliasPanelState = "add"
    SettingsHolder.Visible = false
    AliasCommandInput.Text = ""
    AliasShortcutInput.Text = ""
    AliasClearConfirmFrame.Visible = false
    AliasClearConfirmFrame.Position = aliasPanelHiddenPosition
    AliasesFrame.Visible = true
    AliasesFrame:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
    AliasAddDialog.Visible = true
    AliasAddDialog.Position = aliasPanelHiddenPosition
    AliasAddDialog:TweenPosition(aliasPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
    task.delay(0.52, function()
        if token ~= aliasPanelTransitionToken or aliasPanelState ~= "add" then return end
        AliasesFrame.Visible = false
        AliasCommandInput:CaptureFocus()
    end)
end

local function openAliasClearConfirmation()
    aliasPanelTransitionToken += 1
    local token = aliasPanelTransitionToken
    aliasPanelState = "clearConfirm"
    SettingsHolder.Visible = false
    AliasAddDialog.Visible = false
    AliasAddDialog.Position = aliasPanelHiddenPosition
    AliasesFrame.Visible = true
    AliasesFrame:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
    AliasClearConfirmFrame.Visible = true
    AliasClearConfirmFrame.Position = aliasPanelHiddenPosition
    AliasClearConfirmFrame:TweenPosition(aliasPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
    task.delay(0.52, function()
        if token ~= aliasPanelTransitionToken or aliasPanelState ~= "clearConfirm" then return end
        AliasesFrame.Visible = false
    end)
end

local function closeAliasesSection()
    aliasPanelTransitionToken += 1
    local token = aliasPanelTransitionToken
    aliasPanelState = "settings"
    SettingsHolder.Visible = true
    AliasesFrame:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
    if AliasAddDialog.Visible then AliasAddDialog:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil) end
    if AliasClearConfirmFrame.Visible then AliasClearConfirmFrame:TweenPosition(aliasPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil) end
    task.delay(0.52, function()
        if token ~= aliasPanelTransitionToken or aliasPanelState ~= "settings" then return end
        AliasesFrame.Visible = false
        AliasAddDialog.Visible = false
        AliasClearConfirmFrame.Visible = false
        AliasesFrame.Position = aliasPanelHiddenPosition
        AliasAddDialog.Position = aliasPanelHiddenPosition
        AliasClearConfirmFrame.Position = aliasPanelHiddenPosition
    end)
end

Close_2.MouseButton1Click:Connect(closeAliasesSection)
Aliases.MouseButton1Click:Connect(openAliasesPanel)
AddAliasButton.MouseButton1Click:Connect(openAliasAddPanel)

AliasAddCancel.MouseButton1Click:Connect(function()
    AliasCommandInput:ReleaseFocus()
    AliasShortcutInput:ReleaseFocus()
    AliasCommandInput.Text = ""
    AliasShortcutInput.Text = ""
    returnToAliasesPanel()
end)

local waypointPanelTransitionToken = 0
local waypointPanelState = "hidden"
local waypointPanelHiddenPosition = UDim2.new(0, 0, 0, 200)
local waypointPanelShownPosition = UDim2.new(0, 0, 0, 0)

local function openWaypointClearConfirmation()
	waypointPanelTransitionToken += 1
	local token = waypointPanelTransitionToken
	waypointPanelState = "clearConfirm"
	SettingsHolder.Visible = false
	WaypointAddDialog.Visible = false
	WaypointAddDialog.Position = waypointPanelHiddenPosition
	PositionsFrame.Visible = true
	WaypointClearConfirmFrame.Visible = true
	WaypointClearConfirmFrame.Position = waypointPanelHiddenPosition
	PositionsFrame:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	WaypointClearConfirmFrame:TweenPosition(waypointPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
	task.delay(0.52, function()
		if token ~= waypointPanelTransitionToken or waypointPanelState ~= "clearConfirm" then return end
		PositionsFrame.Visible = false
	end)
end

local function returnToWaypointsPanel()
	waypointPanelTransitionToken += 1
	local token = waypointPanelTransitionToken
	waypointPanelState = "waypoints"
	SettingsHolder.Visible = false
	PositionsFrame.Visible = true
	PositionsFrame.Position = waypointPanelHiddenPosition
	PositionsFrame:TweenPosition(waypointPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
	if WaypointAddDialog.Visible then
		WaypointAddDialog:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	end
	if WaypointClearConfirmFrame.Visible then
		WaypointClearConfirmFrame:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	end
	task.delay(0.52, function()
		if token ~= waypointPanelTransitionToken or waypointPanelState ~= "waypoints" then return end
		WaypointClearConfirmFrame.Visible = false
		WaypointClearConfirmFrame.Position = waypointPanelHiddenPosition
		WaypointAddDialog.Visible = false
		WaypointAddDialog.Position = waypointPanelHiddenPosition
	end)
end

local function openWaypointAddPanel()
	waypointPanelTransitionToken += 1
	local token = waypointPanelTransitionToken
	waypointPanelState = "add"
	SettingsHolder.Visible = false
	WaypointNameInput:ReleaseFocus()
	WaypointNameInput.Text = ""
	WaypointClearConfirmFrame.Visible = false
	WaypointClearConfirmFrame.Position = waypointPanelHiddenPosition
	PositionsFrame.Visible = true
	PositionsFrame:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	WaypointAddDialog.Visible = true
	WaypointAddDialog.Position = waypointPanelHiddenPosition
	WaypointAddDialog:TweenPosition(waypointPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
	task.delay(0.52, function()
		if token ~= waypointPanelTransitionToken or waypointPanelState ~= "add" then return end
		PositionsFrame.Visible = false
	end)
end

Close_3.MouseButton1Click:Connect(function()
	waypointPanelTransitionToken += 1
	local token = waypointPanelTransitionToken
	waypointPanelState = "hidden"
	SettingsHolder.Visible = true
	PositionsFrame:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	if WaypointClearConfirmFrame.Visible then
		WaypointClearConfirmFrame:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	end
	if WaypointAddDialog.Visible then
		WaypointAddDialog:TweenPosition(waypointPanelHiddenPosition, "InOut", "Quart", 0.5, true, nil)
	end
	task.delay(0.52, function()
		if token ~= waypointPanelTransitionToken or waypointPanelState ~= "hidden" then return end
		WaypointClearConfirmFrame.Visible = false
		WaypointClearConfirmFrame.Position = waypointPanelHiddenPosition
		WaypointAddDialog.Visible = false
		WaypointAddDialog.Position = waypointPanelHiddenPosition
	end)
end)

Positions.MouseButton1Click:Connect(function()
	waypointPanelTransitionToken += 1
	local token = waypointPanelTransitionToken
	waypointPanelState = "waypoints"
	WaypointClearConfirmFrame.Visible = false
	WaypointClearConfirmFrame.Position = waypointPanelHiddenPosition
	WaypointAddDialog.Visible = false
	WaypointAddDialog.Position = waypointPanelHiddenPosition
	PositionsFrame.Visible = true
	PositionsFrame:TweenPosition(waypointPanelShownPosition, "InOut", "Quart", 0.5, true, nil)
	task.delay(0.52, function()
		if token ~= waypointPanelTransitionToken or waypointPanelState ~= "waypoints" then return end
		SettingsHolder.Visible = false
	end)
end)

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = randomString()
selectionBox.Color3 = Color3.new(255,255,255)
selectionBox.Adornee = nil
selectionBox.Parent = PARENT

local selected = Instance.new("SelectionBox")
selected.Name = randomString()
selected.Color3 = Color3.new(0,166,0)
selected.Adornee = nil
selected.Parent = PARENT

local ActivateHighlight = nil
local ClickSelect = nil
function selectPart()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, 335), "InOut", "Quart", 0.5, true, nil)
	local function HighlightPart()
		if selected.Adornee ~= IYMouse.Target then
			selectionBox.Adornee = IYMouse.Target
		else
			selectionBox.Adornee = nil
		end
	end
	ActivateHighlight = IYMouse.Move:Connect(HighlightPart)
	local function SelectPart()
		if IYMouse.Target ~= nil then
			selected.Adornee = IYMouse.Target
			Path.Text = getHierarchy(IYMouse.Target)
		end
	end
	ClickSelect = IYMouse.Button1Down:Connect(SelectPart)
end

Exit_4.MouseButton1Click:Connect(function()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	if ActivateHighlight then
		ActivateHighlight:Disconnect()
	end
	if ClickSelect then
		ClickSelect:Disconnect()
	end
	selectionBox.Adornee = nil
	selected.Adornee = nil
	Path.Text = ""
end)

CopyPath.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		toClipboard(Path.Text)
	else
		notify('Copy Path','Select a part to copy its path')
	end
end)

ChoosePart.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		local tpNameExt = ''
		local function handleWpNames()
			local FoundDupe = false
			for i,v in pairs(pWayPoints) do
				if v.NAME:lower() == selected.Adornee.Name:lower()..tpNameExt then
					FoundDupe = true
				end
			end
			if not FoundDupe then
				notify('Modified Waypoints',"Created waypoint: "..selected.Adornee.Name..tpNameExt)
				pWayPoints[#pWayPoints + 1] = {NAME = selected.Adornee.Name..tpNameExt, COORD = {selected.Adornee}}
			else
				if isNumber(tpNameExt) then
					tpNameExt = tpNameExt+1
				else
					tpNameExt = 1
				end
				handleWpNames()
			end
		end
		handleWpNames()
		refreshwaypoints()
	else
		notify('Part Selection','Select a part first')
	end
end)

cmds={}
customAlias = {}

local function trimAliasInput(value)
	return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function isValidAliasToken(value)
	return value ~= "" and #value <= 32 and value:match("^[%w_%-]+$") ~= nil
end

AliasAddDone.MouseButton1Click:Connect(function()
	local commandInput = string.lower(trimAliasInput(AliasCommandInput.Text))
	local aliasInput = string.lower(trimAliasInput(AliasShortcutInput.Text))

	if commandInput == "" or aliasInput == "" then
		notify("Alias Error", "Enter both a command and a shortcut.", 4)
		return
	end

	if not isValidAliasToken(aliasInput) then
		notify("Alias Error", "Shortcut may contain only letters, numbers, underscores, or hyphens (max 32 characters).", 4)
		return
	end

	local command = findCmd and findCmd(commandInput) or nil
	if type(command) ~= "table" or type(command.NAME) ~= "string" or command.NAME == "" then
		notify("Alias Error", "Command '" .. commandInput .. "' was not found.", 4)
		return
	end

	local aliasExists = false
	if findCmd and findCmd(aliasInput) then
		aliasExists = true
	end
	if not aliasExists then
		for _, existing in ipairs(aliases or {}) do
			if type(existing) == "table" and string.lower(tostring(existing.ALIAS or "")) == aliasInput then
				aliasExists = true
				break
			end
		end
	end
	if aliasExists then
		notify("Alias Error", "Shortcut '" .. aliasInput .. "' is already used by a command or alias.", 4)
		return
	end

	local canonicalCommand = string.lower(command.NAME)
	customAlias[aliasInput] = command
	aliases[#aliases + 1] = {CMD = canonicalCommand, ALIAS = aliasInput}
	updatesaves()
	refreshaliases()
	AliasCommandInput:ReleaseFocus()
	AliasShortcutInput:ReleaseFocus()
	AliasCommandInput.Text = ""
	AliasShortcutInput.Text = ""
	returnToAliasesPanel()
	notify("Aliases Modified", "Added '" .. aliasInput .. "' as an alias to '" .. canonicalCommand .. "'.", 4)
end)

Delete_3.MouseButton1Click:Connect(openAliasClearConfirmation)

AliasClearConfirmButton.MouseButton1Click:Connect(function()
	-- Destructive action occurs only after an explicit confirmation.
	customAlias = {}
	aliases = {}
	updatesaves()
	refreshaliases()
	returnToAliasesPanel()
	notify('Aliases Modified','Removed all aliases', 4)
end)

AliasClearCancelButton.MouseButton1Click:Connect(function()
	-- Cancel only closes the confirmation page; it does not mutate aliases.
	returnToAliasesPanel()
end)

function CamViewport()
	if workspace.CurrentCamera then
		return workspace.CurrentCamera.ViewportSize.X
	end
end

function UpdateToViewport()
	if Holder.Position.X.Offset < -CamViewport() then
		Holder:TweenPosition(UDim2.new(1, -CamViewport(), Holder.Position.Y.Scale, Holder.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
		Notification:TweenPosition(UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
	end
end
CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)

function updateCamera(child, parent)
	if parent ~= workspace then
		CamMoved:Disconnect()
		CameraChanged:Disconnect()
		repeat wait() until workspace.CurrentCamera
		CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)
		CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)
	end
end
CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)

local wasStayOpen = StayOpen
local SWIPE_DOWN_HIDE_THRESHOLD = IsOnMobile and 54 or 64

function dragMain(dragpoint,gui)
	task.spawn(function()
		local dragging = false
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local gestureMode = nil

		local function resetGesture()
			dragging = false
			dragInput = nil
			gestureMode = nil
		end

		local function hideFromSwipeDown()
			if gui ~= Holder then return end
			-- Use the same target position, easing, and duration as the normal idle auto-hide.
			-- Keep the floating opener and the Keep Menu Open preference intact.
			isHidden = true
			wasStayOpen = StayOpen
			holderHideToken += 1
			gui:TweenPosition(UDim2.new(1, gui.Position.X.Offset, 1, minimizeNum), "InOut", "Quart", 0.5, true, nil)
		end

		local function update(input)
			local pos = -250
			local delta = input.Position - dragStart
			if startPos.X.Offset + delta.X <= -500 then
				local Position = UDim2.new(1, -250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = 250
			else
				local Position = UDim2.new(1, -500, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = -250
			end
			if startPos.X.Offset + delta.X <= -250 and -CamViewport() <= startPos.X.Offset + delta.X then
				local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + pos, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			elseif startPos.X.Offset + delta.X > -500 then
				local Position = UDim2.new(1, -250, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
			elseif -CamViewport() > startPos.X.Offset + delta.X then
				gui:TweenPosition(UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
				local Position = UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			end
		end

		dragpoint.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position
				dragInput = nil
				gestureMode = nil

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resetGesture()
					end
				end)
			end
		end)

		dragpoint.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputChanged:Connect(function(input)
			if input ~= dragInput or not dragging then return end
			local delta = input.Position - dragStart
			local absX = math.abs(delta.X)
			local absY = math.abs(delta.Y)

			-- Prioritize a clear downward swipe even if small early horizontal jitter
			-- already classified the gesture as horizontal. This makes hide-on-swipe
			-- reliable when the command list is open and the finger path is imperfect.
			if delta.Y > 0 and delta.Y >= SWIPE_DOWN_HIDE_THRESHOLD and delta.Y >= absX * 1.25 then
				gestureMode = "swipeDown"
				hideFromSwipeDown()
				resetGesture()
				return
			end

			if gestureMode == nil then
				-- Ignore taps and small jitter. Lock to an axis before moving the panel.
				if absX < 10 and absY < 10 then return end
				if absX >= 10 and absX >= absY * 1.2 then
					gestureMode = "horizontal"
				elseif absY >= 10 and absY > absX * 1.2 then
					gestureMode = "vertical"
				else
					return
				end
			elseif gestureMode == "vertical" then
				return
			end

			if gestureMode == "horizontal" then
				update(input)
			end
		end))
	end)
end

dragMain(Title,Holder)

Match = function(name,str)
	str = str:gsub("%W", "%%%1")
	return name:lower():find(str:lower()) and true
end

local canvasPos = Vector2.new(0,0)
local topCommand = nil
local function updateCommandCanvasSize(frame)
	local scale = (Scale and Scale.Scale) or 1
	if scale <= 0 then scale = 1 end
	local contentY = cmdListLayout.AbsoluteContentSize.Y
	local unscaledY = math.ceil(contentY / scale)
	frame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, unscaledY))
end
cmdListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateCommandCanvasSize(CMDsF)
end)
IndexContents = function(str,bool,cmdbar,Ianim)
	CMDsF.CanvasPosition = Vector2.new(0,0)
	local SizeY = 0
	local indexnum = 0
	local frame = CMDsF
	topCommand = nil
	local favoriteMatches = 0
	local normalMatches = 0
	local chunks = {}
	if str:sub(#str,#str) == "\\" then str = "" end
	for w in string.gmatch(str,"[^\\]+") do
		table.insert(chunks,w)
	end
	if #chunks > 0 then str = chunks[#chunks] end
	if str:sub(1,1) == "!" then str = str:sub(2) end

	local children = frame:GetChildren()
	table.sort(children, function(a, b)
		local aOrder = a:IsA("GuiObject") and a.LayoutOrder or -100000
		local bOrder = b:IsA("GuiObject") and b.LayoutOrder or -100000
		if aOrder == bOrder then return a.Name < b.Name end
		return aOrder < bOrder
	end)

	for _, v in ipairs(children) do
		if v:GetAttribute("IsCommandSectionHeader") or v:GetAttribute("IsCommandEmptyState") then
			v.Visible = false
		elseif v:GetAttribute("IsCommandEntry") then
			local matched = (not bool) or Match(v.Text, str)
			v.Visible = matched
			if matched then
				if bool then indexnum = indexnum + 1 end
				if topCommand == nil then topCommand = v.Text end
				if v:GetAttribute("IsFavoriteCommand") then
					favoriteMatches = favoriteMatches + 1
				else
					normalMatches = normalMatches + 1
				end
			end
		elseif v:IsA("TextButton") or v:IsA("TextLabel") then
			-- Keep the original filtering behavior for any non-command UI element.
			if bool then
				if Match(v.Text,str) then
					indexnum = indexnum + 1
					v.Visible = true
					if topCommand == nil then topCommand = v.Text end
				else
					v.Visible = false
				end
			else
				v.Visible = true
				if topCommand == nil then topCommand = v.Text end
			end
		end
	end

	if FavSectionHeader then
		FavSectionHeader.Visible = (not bool) or str == "" or favoriteMatches > 0
	end
	if AllCommandsHeader then
		AllCommandsHeader.Visible = (not bool) or str == "" or normalMatches > 0
	end
	if FavEmptyLabel then
		FavEmptyLabel.Visible = (#(favoriteCommands or {}) == 0) and ((not bool) or str == "")
	end

	updateCommandCanvasSize(frame)
	if not Ianim then
		if indexnum == 0 or string.find(str, " ") then
			if not cmdbar then
				minimizeHolder()
			elseif cmdbar then
				cmdbarHolder()
			end
		else
			maximizeHolder()
		end
	else
		minimizeHolder()
	end
end

task.spawn(function()
	if not isLegacyChat then return end
	local chatbox
	local success, result = pcall(function() chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
	if success then
		local function chatboxFocused()
			canvasPos = CMDsF.CanvasPosition
		end
		local chatboxFocusedC = IY_RELOAD_INSTANCE_STATE.TrackConnection(chatbox.Focused:Connect(chatboxFocused))

		local function Index()
			if chatbox.Text:lower():sub(1,1) == prefix then
				if SettingsOpen == true then
					-- Keep the settings panel in front without disabling normal command indexing.
					CMDsF.Visible = false
					setSettingsBackdrop(true)
				end
				IndexContents(PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar.Text:lower():sub(2),true)
			else
				minimizeHolder()
				if SettingsOpen == true then
					wait(0.2)
					Settings:TweenPosition(UDim2.new(0, 0, 0, 20), "InOut", "Quart", 0.2, true, nil)
					CMDsF.Visible = false
					setSettingsBackdrop(true)
				end
			end
		end
		local chatboxFunc = IY_RELOAD_INSTANCE_STATE.TrackConnection(chatbox:GetPropertyChangedSignal("Text"):Connect(Index))

		local function chatboxFocusLost(enterpressed)
			if not enterpressed or chatbox.Text:lower():sub(1,1) ~= prefix then
				IndexContents('',true)
			end
			CMDsF.CanvasPosition = canvasPos
			minimizeHolder()
		end
		local chatboxFocusLostC = IY_RELOAD_INSTANCE_STATE.TrackConnection(chatbox.FocusLost:Connect(chatboxFocusLost))

		IY_RELOAD_INSTANCE_STATE.TrackConnection(PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.ChildAdded:Connect(function(newbar)
			wait()
			if newbar:FindFirstChild('BoxFrame') then
				chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
				if chatboxFocusedC then chatboxFocusedC:Disconnect() end
				chatboxFocusedC = IY_RELOAD_INSTANCE_STATE.TrackConnection(chatbox.Focused:Connect(chatboxFocused))
				if chatboxFunc then chatboxFunc:Disconnect() end
				chatboxFunc = IY_RELOAD_INSTANCE_STATE.TrackConnection(chatbox:GetPropertyChangedSignal("Text"):Connect(Index))
				if chatboxFocusLostC then chatboxFocusLostC:Disconnect() end
				chatboxFocusLostC = IY_RELOAD_INSTANCE_STATE.TrackConnection(chatbox.FocusLost:Connect(chatboxFocusLost))
			end
		end))
		--else
		--print('Custom chat detected. Will not provide suggestions for commands typed in the chat.')
	end
end)

function autoComplete(str,curText)
	local endingChar = {"[", "/", "(", " "}
	local stop = 0
	for i=1,#str do
		local c = str:sub(i,i)
		if table.find(endingChar, c) then
			stop = i
			break
		end
	end
	curText = curText or Cmdbar.Text
	local subPos = 0
	local pos = 1
	local findRes = string.find(curText,"\\",pos)
	while findRes do
		subPos = findRes
		pos = findRes+1
		findRes = string.find(curText,"\\",pos)
	end
	if curText:sub(subPos+1,subPos+1) == "!" then subPos = subPos + 1 end
	Cmdbar.Text = curText:sub(1,subPos) .. str:sub(1, stop - 1)..' '
	RunService.RenderStepped:Wait()
	Cmdbar.Text = Cmdbar.Text:gsub( '\t', '' )
	Cmdbar.CursorPosition = #Cmdbar.Text+1--1020
end

CMDs = {}
CMDs[#CMDs + 1] = {NAME = 'discord / support / help', DESC = 'Invite to the Infinite Yield discord server.'}
CMDs[#CMDs + 1] = {NAME = 'guiscale [number]', DESC = 'Changes the size of the gui. [number] accepts decimals and whole numbers. Min is 0.4 and Max is 2'}
CMDs[#CMDs + 1] = {NAME = 'console', DESC = 'Opens the Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'oldconsole', DESC = 'Loads an old-themed Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'explorer / dex', DESC = 'Opens Dex++ by Chillz'}
CMDs[#CMDs + 1] = {NAME = 'moondex / mdex', DESC = 'Opens DEX by Moon'}
CMDs[#CMDs + 1] = {NAME = 'remotespy / rspy', DESC = 'Opens Cobalt to intercept incoming and outgoing network traffic'}
CMDs[#CMDs + 1] = {NAME = 'simplespy / sspy', DESC = 'Opens Simple Spy V3 to intercept remote calls from the client to the server'}
CMDs[#CMDs + 1] = {NAME = 'audiologger / alogger', DESC = 'Opens Edges audio logger'}
CMDs[#CMDs + 1] = {NAME = 'serverinfo / info', DESC = 'Gives you info about the server'}
CMDs[#CMDs + 1] = {NAME = 'jobid', DESC = 'Copies the games JobId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'notifyjobid', DESC = 'Notifies you the games JobId'}
CMDs[#CMDs + 1] = {NAME = 'rejoin / rj [reposition]', DESC = 'Makes you rejoin the game'}
CMDs[#CMDs + 1] = {NAME = 'inviteprompt', DESC = 'Prompts the user of your choice that they had invited you. Requires a rejoin to function.'}
CMDs[#CMDs + 1] = {NAME = 'autorejoin / autorj', DESC = 'Automatically rejoins the server if you get kicked/disconnected'}
CMDs[#CMDs + 1] = {NAME = 'serverhop / shop', DESC = 'Teleports you to a different server'}
CMDs[#CMDs + 1] = {NAME = 'gameteleport / gametp [place ID]', DESC = 'Joins a game by ID'}
CMDs[#CMDs + 1] = {NAME = 'antiidle / antiafk', DESC = 'Prevents the game from kicking you for being idle/afk'}
CMDs[#CMDs + 1] = {NAME = 'datalimit [num]', DESC = 'Set outgoing KBPS limit'}
CMDs[#CMDs + 1] = {NAME = 'replicationlag / backtrack [num]', DESC = 'Set IncomingReplicationLag'}
CMDs[#CMDs + 1] = {NAME = 'creatorid / creator', DESC = 'Notifies you the creators ID'}
CMDs[#CMDs + 1] = {NAME = 'copycreatorid / copycreator', DESC = 'Copies the creators ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'setcreatorid / setcreator', DESC = 'Sets your userid to the creators ID'}
CMDs[#CMDs + 1] = {NAME = 'noprompts', DESC = 'Prevents the game from showing you purchase/premium prompts'}
CMDs[#CMDs + 1] = {NAME = 'showprompts', DESC = 'Allows the game to show purchase/premium prompts again'}
CMDs[#CMDs + 1] = {NAME = 'enable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of coregui items'}
CMDs[#CMDs + 1] = {NAME = 'disable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of coregui items'}
CMDs[#CMDs + 1] = {NAME = 'showguis', DESC = 'Shows any invisible GUIs'}
CMDs[#CMDs + 1] = {NAME = 'unshowguis', DESC = 'Undoes showguis'}
CMDs[#CMDs + 1] = {NAME = 'hideguis', DESC = 'Hides any GUIs in PlayerGui'}
CMDs[#CMDs + 1] = {NAME = 'unhideguis', DESC = 'Undoes hideguis'}
CMDs[#CMDs + 1] = {NAME = 'guidelete', DESC = 'Enables backspace to delete GUI'}
CMDs[#CMDs + 1] = {NAME = 'unguidelete / noguidelete', DESC = 'Disables guidelete'}
CMDs[#CMDs + 1] = {NAME = 'hideiy', DESC = 'Hides the main IY GUI'}
CMDs[#CMDs + 1] = {NAME = 'showiy / unhideiy', DESC = 'Shows IY again'}
CMDs[#CMDs + 1] = {NAME = 'reload', DESC = 'Fetches the latest Infinite Yield Cruzan script from GitHub and reloads it'}
CMDs[#CMDs + 1] = {NAME = 'keepiy', DESC = 'Auto execute IY when you teleport through servers'}
CMDs[#CMDs + 1] = {NAME = 'unkeepiy', DESC = 'Disable keepiy'}
CMDs[#CMDs + 1] = {NAME = 'togglekeepiy', DESC = 'Toggles keepiy'}
CMDs[#CMDs + 1] = {NAME = 'removeads / adblock', DESC = 'Automatically removes ad billboards'}
CMDs[#CMDs + 1] = {NAME = 'savegame / saveplace', DESC = 'Uses saveinstance to save the game'}
CMDs[#CMDs + 1] = {NAME = 'clearerror', DESC = 'Clears the annoying box and blur when a game kicks you'}
CMDs[#CMDs + 1] = {NAME = 'antigameplaypaused', DESC = 'Clears the annoying box shown when a game is loading assets due to network lag'}
CMDs[#CMDs + 1] = {NAME = 'unantigameplaypaused', DESC = 'Disables antigameplaypaused'}
CMDs[#CMDs + 1] = {NAME = 'clientantikick / antikick (CLIENT)', DESC = 'Prevents localscripts from kicking you'}
CMDs[#CMDs + 1] = {NAME = 'clientantiteleport / antiteleport (CLIENT)', DESC = 'Prevents localscripts from teleporting you'}
CMDs[#CMDs + 1] = {NAME = 'allowrejoin / allowrj (CLIENT)', DESC = 'Toggles if antiteleport allows you to rejoin or not'}
CMDs[#CMDs + 1] = {NAME = 'cancelteleport / canceltp', DESC = 'Cancels teleports in progress'}
CMDs[#CMDs + 1] = {NAME = 'volume / vol [0-10]', DESC = 'Adjusts your game volume on a scale of 0 to 10'}
CMDs[#CMDs + 1] = {NAME = 'antilag / boostfps / lowgraphics', DESC = 'Lowers game quality to boost FPS'}
CMDs[#CMDs + 1] = {NAME = 'rec', DESC = 'Starts or stops the built-in Roblox recorder'}
CMDs[#CMDs + 1] = {NAME = 'record [start/play/loop/stop/clear]', DESC = 'Opens the floating movement recorder controls'}
CMDs[#CMDs + 1] = {NAME = 'screenshot / scrnshot', DESC = 'Takes a screenshot'}
CMDs[#CMDs + 1] = {NAME = 'togglefullscreen / togglefs', DESC = 'Toggles fullscreen'}
CMDs[#CMDs + 1] = {NAME = 'notify [text]', DESC = 'Sends you a notification with the provided text'}
CMDs[#CMDs + 1] = {NAME = 'lastcommand / lastcmd', DESC = 'Executes the previous command used'}
CMDs[#CMDs + 1] = {NAME = 'notifyping / ping', DESC = 'Notify yourself your ping'}
CMDs[#CMDs + 1] = {NAME = 'norender', DESC = 'Disable 3d Rendering to decrease the amount of CPU the client uses'}
CMDs[#CMDs + 1] = {NAME = 'render', DESC = 'Enable 3d Rendering'}
CMDs[#CMDs + 1] = {NAME = 'use2022materials / 2022materials', DESC = 'Enables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'unuse2022materials / un2022materials', DESC = 'Disables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'alignmentkeys', DESC = 'Enables the left and right alignment keys (comma and period)'}
CMDs[#CMDs + 1] = {NAME = 'unalignmentkeys / noalignmentkeys', DESC = 'Disables the alignment keys'}
CMDs[#CMDs + 1] = {NAME = 'ctrllock', DESC = 'Binds Shiftlock to LeftControl'}
CMDs[#CMDs + 1] = {NAME = 'unctrllock', DESC = 'Re-binds Shiftlock to LeftShift'}
CMDs[#CMDs + 1] = {NAME = 'exit / shutdown / leave', DESC = 'Exits the game'}
CMDs[#CMDs + 1] = {NAME = 'removecmd / deletecmd', DESC = 'Removes a command until the script is reloaded'}
CMDs[#CMDs + 1] = {NAME = 'breakloops / break (cmd loops)', DESC = 'Stops any cmd loops (;100^1^cmd)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'noclip', DESC = 'Go through objects'}
CMDs[#CMDs + 1] = {NAME = 'unnoclip / clip', DESC = 'Disables noclip'}
CMDs[#CMDs + 1] = {NAME = 'fly [speed]', DESC = 'Makes you fly'}
CMDs[#CMDs + 1] = {NAME = 'unfly', DESC = 'Disables fly'}
CMDs[#CMDs + 1] = {NAME = 'flyspeed [num]', DESC = 'Set fly speed (default is 20)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclefly / vfly [speed]', DESC = 'Makes you fly in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'unvehiclefly / unvfly', DESC = 'Disables vehicle fly'}
CMDs[#CMDs + 1] = {NAME = 'vehicleflyspeed  / vflyspeed [num]', DESC = 'Set vehicle fly speed'}
CMDs[#CMDs + 1] = {NAME = 'cframefly / cfly [speed]', DESC = 'Makes you fly, bypassing some anti cheats (works on mobile)'}
CMDs[#CMDs + 1] = {NAME = 'uncframefly / uncfly', DESC = 'Disables cfly'}
CMDs[#CMDs + 1] = {NAME = 'cframeflyspeed  / cflyspeed [num]', DESC = 'Sets cfly speed'}
CMDs[#CMDs + 1] = {NAME = 'qefly [true / false]', DESC = 'Enables or disables the Q and E hotkeys for fly'}
CMDs[#CMDs + 1] = {NAME = 'vehiclenoclip / vnoclip', DESC = 'Turns off vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'vehicleclip / vclip / unvnoclip', DESC = 'Enables vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'float /  platform', DESC = 'Spawns a platform beneath you causing you to float'}
CMDs[#CMDs + 1] = {NAME = 'unfloat / noplatform', DESC = 'Removes the platform'}
CMDs[#CMDs + 1] = {NAME = 'swim', DESC = 'Allows you to swim in the air'}
CMDs[#CMDs + 1] = {NAME = 'unswim / noswim', DESC = 'Stops you from swimming everywhere'}
CMDs[#CMDs + 1] = {NAME = 'toggleswim', DESC = 'Toggles swimming'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'setwaypoint / swp [name]', DESC = 'Sets a waypoint at your position'}
CMDs[#CMDs + 1] = {NAME = 'waypointpos / wpp [name] [X Y Z]', DESC = 'Sets a waypoint with specified coordinates'}
CMDs[#CMDs + 1] = {NAME = 'waypoints', DESC = 'Shows a list of currently active waypoints'}
CMDs[#CMDs + 1] = {NAME = 'showwaypoints / showwp', DESC = 'Shows all currently set waypoints'}
CMDs[#CMDs + 1] = {NAME = 'hidewaypoints / hidewp', DESC = 'Hides shown waypoints'}
CMDs[#CMDs + 1] = {NAME = 'waypoint / wp [name]', DESC = 'Teleports player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'tweenwaypoint / twp [name]', DESC = 'Tweens player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'walktowaypoint / wtwp [name]', DESC = 'Walks player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'deletewaypoint / dwp [name]', DESC = 'Deletes a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'clearwaypoints / cwp', DESC = 'Clears all waypoints'}
CMDs[#CMDs + 1] = {NAME = 'cleargamewaypoints / cgamewp', DESC = 'Clears all waypoints for the game you are in'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'goto [player] [request stream]', DESC = 'Go to a player'}
CMDs[#CMDs + 1] = {NAME = 'tweengoto / tgoto [player]', DESC = 'Tween to a player (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'tweenspeed / tspeed [num]', DESC = 'Sets how fast all tween commands go (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclegoto / vgoto [player]', DESC = 'Go to a player while in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'loopgoto [player] [distance] [delay]', DESC = 'Loop teleport to a player'}
CMDs[#CMDs + 1] = {NAME = 'unloopgoto', DESC = 'Stops teleporting you to a player'}
CMDs[#CMDs + 1] = {NAME = 'pulsetp / ptp [player] [seconds]', DESC = 'Teleports you to a player for a specified amount of time'}
CMDs[#CMDs + 1] = {NAME = 'clientbring / cbring [player] (CLIENT)', DESC = 'Bring a player'}
CMDs[#CMDs + 1] = {NAME = 'loopbring [player] [distance] [delay] (CLIENT)', DESC = 'Loop brings a player to you (useful for killing)'}
CMDs[#CMDs + 1] = {NAME = 'unloopbring [player]', DESC = 'Undoes loopbring'}
CMDs[#CMDs + 1] = {NAME = 'freeze / fr [player] (CLIENT)', DESC = 'Freezes a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeanims', DESC = 'Freezes your animations / pauses your animations - Does not work on default animations'}
CMDs[#CMDs + 1] = {NAME = 'unfreezeanims', DESC = 'Unfreezes your animations / plays your animations'}
CMDs[#CMDs + 1] = {NAME = 'thaw / unfr [player] (CLIENT)', DESC = 'Unfreezes a player'}
CMDs[#CMDs + 1] = {NAME = 'anchor', DESC = 'Anchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'unanchor', DESC = 'Unanchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'tpposition / tppos [X Y Z]', DESC = 'Teleports you to certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweentpposition / ttppos [X Y Z]', DESC = 'Tween to coordinates (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'offset [X Y Z]', DESC = 'Offsets you by certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweenoffset / toffset [X Y Z]', DESC = 'Tween offset (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'thru [num]', DESC = 'Teleports you [num] studs ahead of where your character is facing'}
CMDs[#CMDs + 1] = {NAME = 'notifyposition / notifypos [player]', DESC = 'Notifies you the coordinates of a character'}
CMDs[#CMDs + 1] = {NAME = 'copyposition / copypos [player]', DESC = 'Copies the coordinates of a character to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'walktoposition / walktopos [X Y Z]', DESC = 'Makes you walk to a coordinate'}
CMDs[#CMDs + 1] = {NAME = 'spawnpoint / spawn [delay]', DESC = 'Sets a position where you will spawn'}
CMDs[#CMDs + 1] = {NAME = 'nospawnpoint / nospawn', DESC = 'Removes your custom spawn point'}
CMDs[#CMDs + 1] = {NAME = 'flashback / diedtp', DESC = 'Teleports you to where you last died'}
CMDs[#CMDs + 1] = {NAME = 'walltp', DESC = 'Teleports you above/over any wall you run into'}
CMDs[#CMDs + 1] = {NAME = 'nowalltp / unwalltp', DESC = 'Disables walltp'}
CMDs[#CMDs + 1] = {NAME = 'teleporttool / tptool', DESC = 'Gives you a teleport tool'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'logs', DESC = 'Opens the logs GUI'}
CMDs[#CMDs + 1] = {NAME = 'chatlogs / clogs', DESC = 'Log what people say or whisper'}
CMDs[#CMDs + 1] = {NAME = 'joinlogs / jlogs', DESC = 'Log when people join'}
CMDs[#CMDs + 1] = {NAME = 'chatlogswebhook / logswebhook [url]', DESC = 'Set a discord webhook for chatlogs to go to (provide no url to disable this)'}
CMDs[#CMDs + 1] = {NAME = 'chat / say [text]', DESC = 'Makes you chat a string (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'spam [text]', DESC = 'Makes you spam the chat'}
CMDs[#CMDs + 1] = {NAME = 'unspam', DESC = 'Turns off spam'}
CMDs[#CMDs + 1] = {NAME = 'whisper / pm [player] [text]', DESC = 'Makes you whisper a string to someone (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'pmspam [player] [text]', DESC = 'Makes you spam a players whispers'}
CMDs[#CMDs + 1] = {NAME = 'unpmspam [player]', DESC = 'Turns off pm spam'}
CMDs[#CMDs + 1] = {NAME = 'spamspeed [num]', DESC = 'How quickly you spam (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'bubblechat (CLIENT)', DESC = 'Enables bubble chat for your client'}
CMDs[#CMDs + 1] = {NAME = 'unbubblechat / nobubblechat', DESC = 'Disables the bubblechat command'}
CMDs[#CMDs + 1] = {NAME = 'chatwindow', DESC = 'Enables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'unchatwindow / nochatwindow', DESC = 'Disables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'darkchat', DESC = 'Makes the chat window dark for your client'}
CMDs[#CMDs + 1] = {NAME = 'listento [player]', DESC = 'Listens to the area around a player. Can also eavesdrop with vc'}
CMDs[#CMDs + 1] = {NAME = 'unlistento', DESC = 'Disables listento'}
CMDs[#CMDs + 1] = {NAME = 'muteallvoices / muteallvcs', DESC = 'Mutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'unmuteallvoices / unmuteallvcs', DESC = 'Unmutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'mutevc [player]', DESC = 'Mutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'unmutevc [player]', DESC = 'Unmutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'phonebook / call', DESC = 'Prompts the Roblox phonebook UI to let you call your friends. Needs voice chat enabled'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'esp', DESC = 'View all players and their status'}
CMDs[#CMDs + 1] = {NAME = 'espteam', DESC = 'ESP but teammates are green and bad guys are red'}
CMDs[#CMDs + 1] = {NAME = 'noesp / unesp / unespteam', DESC = 'Removes ESP'}
CMDs[#CMDs + 1] = {NAME = 'esptransparency [number]', DESC = 'Changes the transparency of ESP related commands'}
CMDs[#CMDs + 1] = {NAME = 'partesp [part name]', DESC = 'Highlights a part'}
CMDs[#CMDs + 1] = {NAME = 'unpartesp / nopartesp [part name]', DESC = 'removes partesp'}
CMDs[#CMDs + 1] = {NAME = 'chams', DESC = 'ESP but without text in the way'}
CMDs[#CMDs + 1] = {NAME = 'nochams / unchams', DESC = 'Removes chams'}
CMDs[#CMDs + 1] = {NAME = 'locate [player]', DESC = 'View a single player and their status'}
CMDs[#CMDs + 1] = {NAME = 'unlocate / nolocate [player]', DESC = 'Removes locate'}
CMDs[#CMDs + 1] = {NAME = 'xray', DESC = 'Makes all parts in workspace transparent'}
CMDs[#CMDs + 1] = {NAME = 'unxray / noxray', DESC = 'Restores transparency to all parts in workspace'}
CMDs[#CMDs + 1] = {NAME = 'loopxray', DESC = 'Makes all parts in workspace transparent but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopxray', DESC = 'Unloops xray'}
CMDs[#CMDs + 1] = {NAME = 'togglexray', DESC = 'Toggles xray'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'spectate / view [player]', DESC = 'View a player'}
CMDs[#CMDs + 1] = {NAME = 'viewpart / viewp [part name]', DESC = 'View a part'}
CMDs[#CMDs + 1] = {NAME = 'unspectate / unview', DESC = 'Stops viewing player'}
CMDs[#CMDs + 1] = {NAME = 'freecam / fc', DESC = 'Allows you to freely move camera around the game'}
CMDs[#CMDs + 1] = {NAME = 'freecampos / fcpos [X Y Z]', DESC = 'Moves / opens freecam in a certain position'}
CMDs[#CMDs + 1] = {NAME = 'freecamwaypoint / fcwp [name]', DESC = 'Moves / opens freecam to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'freecamgoto / fcgoto / fctp [player]', DESC = 'Moves / opens freecam to a player'}
CMDs[#CMDs + 1] = {NAME = 'unfreecam / unfc', DESC = 'Disables freecam'}
CMDs[#CMDs + 1] = {NAME = 'freecamspeed / fcspeed [num]', DESC = 'Adjusts freecam speed (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'notifyfreecamposition / notifyfcpos', DESC = 'Noitifies you your freecam coordinates'}
CMDs[#CMDs + 1] = {NAME = 'copyfreecamposition / copyfcpos', DESC = 'Copies your freecam coordinates to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'gotocamera / gotocam', DESC = 'Teleports you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'tweengotocam / tgotocam', DESC = 'Tweens you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'firstp', DESC = 'Forces camera to go into first person'}
CMDs[#CMDs + 1] = {NAME = 'thirdp', DESC = 'Allows camera to go into third person'}
CMDs[#CMDs + 1] = {NAME = 'noclipcam / nccam', DESC = 'Allows camera to go through objects like walls'}
CMDs[#CMDs + 1] = {NAME = 'maxzoom [num]', DESC = 'Maximum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'minzoom [num]', DESC = 'Minimum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'camdistance [num]', DESC = 'Changes camera distance from your player'}
CMDs[#CMDs + 1] = {NAME = 'fov [num]', DESC = 'Adjusts field of view (default is 70)'}
CMDs[#CMDs + 1] = {NAME = 'fixcam / restorecam', DESC = 'Fixes camera'}
CMDs[#CMDs + 1] = {NAME = 'enableshiftlock / enablesl', DESC = 'Enables the shift lock option'}
CMDs[#CMDs + 1] = {NAME = 'lookat [player]', DESC = 'Moves your camera view to a player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'btools (CLIENT)', DESC = 'Gives you building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'f3x (CLIENT)', DESC = 'Gives you F3X building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'partname / partpath', DESC = 'Allows you to click a part to see its path & name'}
CMDs[#CMDs + 1] = {NAME = 'delete [instance name] (CLIENT)', DESC = 'Removes any part with a certain name from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'deleteclass / dc [class name] (CLIENT)', DESC = 'Removes any part with a certain classname from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'lockworkspace / lockws', DESC = 'Locks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'unlockworkspace / unlockws', DESC = 'Unlocks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'invisibleparts / invisparts (CLIENT)', DESC = 'Shows invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'uninvisibleparts / uninvisparts (CLIENT)', DESC = 'Makes parts affected by invisparts return to normal'}
CMDs[#CMDs + 1] = {NAME = 'deleteinvisparts / dip (CLIENT)', DESC = 'Deletes invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopart [part name]', DESC = 'Moves your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopart / tgotopart [part name]', DESC = 'Tweens your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopartclass / gpc [class name]', DESC = 'Moves your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopartclass / tgpc [class name]', DESC = 'Tweens your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'gotomodel [part name]', DESC = 'Moves your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'tweengotomodel / tgotomodel [part name]', DESC = 'Tweens your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'gotopartdelay / gotomodeldelay [num]', DESC = 'Adjusts how quickly you teleport to each part (default is 0.1)'}
CMDs[#CMDs + 1] = {NAME = 'bringpart [part name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character'}
CMDs[#CMDs + 1] = {NAME = 'bringpartclass / bpc [class name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character based on classname'}
CMDs[#CMDs + 1] = {NAME = 'noclickdetectorlimits / nocdlimits', DESC = 'Sets all click detectors MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireclickdetectors / firecd [name]', DESC = 'Uses all click detectors in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'firetouchinterests / touchinterests [name]', DESC = 'Uses all touchinterests in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'noproximitypromptlimits / nopplimits', DESC = 'Sets all proximity prompts MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireproximityprompts / firepp [name]', DESC = 'Uses all proximity prompts in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'instantproximityprompts / instantpp', DESC = 'Disable the cooldown for proximity prompts'}
CMDs[#CMDs + 1] = {NAME = 'uninstantproximityprompts / uninstantpp', DESC = 'Undo the cooldown removal'}
CMDs[#CMDs + 1] = {NAME = 'tpunanchored / tpua [player]', DESC = 'Teleports unanchored parts to a player'}
CMDs[#CMDs + 1] = {NAME = 'animsunanchored / freezeua', DESC = 'Freezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'thawunanchored / thawua / unfreezeua', DESC = 'Thaws unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'removeterrain / rterrain / noterrain', DESC = 'Removes all terrain'}
CMDs[#CMDs + 1] = {NAME = 'clearnilinstances / nonilinstances / cni', DESC = 'Removes nil instances'}
CMDs[#CMDs + 1] = {NAME = 'destroyheight / dh [num]', DESC = 'Sets FallenPartsDestroyHeight'}
CMDs[#CMDs + 1] = {NAME = 'fakeout', DESC = 'Tp to the void and then back (useful to kill people attached to you)'}
CMDs[#CMDs + 1] = {NAME = 'antivoid', DESC = 'Prevents you from falling into the void by launching you upwards'}
CMDs[#CMDs + 1] = {NAME = 'unantivoid / noantivoid', DESC = 'Disables antivoid'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'fullbright / fb (CLIENT)', DESC = 'Makes the map brighter / more visible'}
CMDs[#CMDs + 1] = {NAME = 'loopfullbright / loopfb (CLIENT)', DESC = 'Makes the map brighter / more visible but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopfullbright / unloopfb', DESC = 'Unloops fullbright'}
CMDs[#CMDs + 1] = {NAME = 'ambient [num] [num] [num] (CLIENT)', DESC = 'Changes ambient'}
CMDs[#CMDs + 1] = {NAME = 'day (CLIENT)', DESC = 'Changes the time to day for the client'}
CMDs[#CMDs + 1] = {NAME = 'night (CLIENT)', DESC = 'Changes the time to night for the client'}
CMDs[#CMDs + 1] = {NAME = 'nofog (CLIENT)', DESC = 'Removes fog'}
CMDs[#CMDs + 1] = {NAME = 'brightness [num] (CLIENT)', DESC = 'Changes the brightness lighting property'}
CMDs[#CMDs + 1] = {NAME = 'globalshadows / gshadows (CLIENT)', DESC = 'Enables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'noglobalshadows / nogshadows (CLIENT)', DESC = 'Disables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'restorelighting / rlighting', DESC = 'Restores Lighting properties'}
CMDs[#CMDs + 1] = {NAME = 'light [radius] [brightness] (CLIENT)', DESC = 'Gives your player dynamic light'}
CMDs[#CMDs + 1] = {NAME = 'nolight / unlight', DESC = 'Removes dynamic light from your player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'inspect / examine [player]', DESC = 'Opens InspectMenu for a certain player'}
CMDs[#CMDs + 1] = {NAME = 'age [player]', DESC = 'Tells you the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'chatage [player]', DESC = 'Chats the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'joindate / jd [player]', DESC = 'Tells you the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'chatjoindate / cjd [player]', DESC = 'Chats the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'copyname / copyuser [player]', DESC = 'Copies a players full username to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'userid / id [player]', DESC = 'Notifies a players user ID'}
CMDs[#CMDs + 1] = {NAME = 'copyplaceid / placeid', DESC = 'Copies the current place id to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copygameid / gameid', DESC = 'Copies the current game id to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copyuserid / copyid [player]', DESC = 'Copies a players user ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'appearanceid / aid [player]', DESC = 'Notifies a players appearance ID'}
CMDs[#CMDs + 1] = {NAME = 'copyappearanceid / caid [player]', DESC = 'Copies a players appearance ID to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'bang [player] [speed]', DESC = 'owo'}
CMDs[#CMDs + 1] = {NAME = 'unbang', DESC = 'uwu'}
CMDs[#CMDs + 1] = {NAME = 'jerk', DESC = 'Makes you jork it'}
CMDs[#CMDs + 1] = {NAME = 'scare / spook [player]', DESC = 'Teleports in front of a player for half a second'}
CMDs[#CMDs + 1] = {NAME = 'carpet [player]', DESC = 'Be someones carpet'}
CMDs[#CMDs + 1] = {NAME = 'uncarpet', DESC = 'Undoes carpet'}
CMDs[#CMDs + 1] = {NAME = 'friend [player]', DESC = 'Sends a friend request to certain players'}
CMDs[#CMDs + 1] = {NAME = 'unfriend [player]', DESC = 'Unfriends certain players'}
CMDs[#CMDs + 1] = {NAME = 'headsit [player]', DESC = 'Sit on a players head'}
CMDs[#CMDs + 1] = {NAME = 'walkto / follow [player]', DESC = 'Follow a player'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalkto / pathfindfollow [player]', DESC = 'Follow a player using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalktowaypoint / pathfindwalktowp [waypoint]', DESC = 'Walk to a waypoint using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'unwalkto / unfollow', DESC = 'Stops following a player'}
CMDs[#CMDs + 1] = {NAME = 'orbit [player] [speed] [distance]', DESC = 'Makes your character orbit around a player with an optional speed and an optional distance'}
CMDs[#CMDs + 1] = {NAME = 'unorbit', DESC = 'Disables orbit'}
CMDs[#CMDs + 1] = {NAME = 'stareat / stare [player]', DESC = 'Stare / look at a player'}
CMDs[#CMDs + 1] = {NAME = 'unstareat / unstare [player]', DESC = 'Disables stareat'}
CMDs[#CMDs + 1] = {NAME = 'rolewatch [group id] [role name]', DESC = 'Notify if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchstop / unrolewatch', DESC = 'Disable Rolewatch'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchleave', DESC = 'Toggle if you should leave the game if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'staffwatch', DESC = 'Notify if a staff member of the game joins the server'}
CMDs[#CMDs + 1] = {NAME = 'unstaffwatch', DESC = 'Disable Staffwatch'}
CMDs[#CMDs + 1] = {NAME = 'findfriendgroups', DESC = 'Notifies you if any players are friends with each other'}
CMDs[#CMDs + 1] = {NAME = 'handlekill / hkill [player] [radius] (TOOL)', DESC = 'Kills a player using tool damage (YOU NEED A TOOL)'}
CMDs[#CMDs + 1] = {NAME = 'fling', DESC = 'Flings anyone you touch'}
CMDs[#CMDs + 1] = {NAME = 'unfling', DESC = 'Disables the fling command'}
CMDs[#CMDs + 1] = {NAME = 'flyfling [speed]', DESC = 'Basically the invisfling command but not invisible'}
CMDs[#CMDs + 1] = {NAME = 'unflyfling', DESC = 'Disables the flyfling command'}
CMDs[#CMDs + 1] = {NAME = 'walkfling', DESC = 'Basically fling but no spinning'}
CMDs[#CMDs + 1] = {NAME = 'unwalkfling / nowalkfling', DESC = 'Disables walkfling'}
CMDs[#CMDs + 1] = {NAME = 'invisfling', DESC = 'Enables invisible fling (the invis part is patched, try using the god command before using this)'}
CMDs[#CMDs + 1] = {NAME = 'antifling', DESC = 'Disables player collisions to prevent you from being flung'}
CMDs[#CMDs + 1] = {NAME = 'unantifling', DESC = 'Disables antifling'}
CMDs[#CMDs + 1] = {NAME = 'loopoof', DESC = 'Loops everyones character sounds (everyone can hear)'}
CMDs[#CMDs + 1] = {NAME = 'unloopoof', DESC = 'Stops the oof chaos'}
CMDs[#CMDs + 1] = {NAME = 'muteboombox [player]', DESC = 'Mutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'unmuteboombox [player]', DESC = 'Unmutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'hitboxes', DESC = 'Shows all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'unhitboxes', DESC = 'Stops showing all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'hitbox [player] [size] [transparency]', DESC = 'Expands the hitbox for players HumanoidRootPart (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'headsize [player] [size]', DESC = 'Expands the head size for players Head (default is 1)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'reset', DESC = 'Resets your character normally'}
CMDs[#CMDs + 1] = {NAME = 'respawn', DESC = 'Respawns you'}
CMDs[#CMDs + 1] = {NAME = 'refresh / re', DESC = 'Respawns and brings you back to the same position'}
CMDs[#CMDs + 1] = {NAME = 'god', DESC = 'Makes your character difficult to kill in most games'}
CMDs[#CMDs + 1] = {NAME = 'invisible / invis', DESC = 'Makes you invisible to other players'}
CMDs[#CMDs + 1] = {NAME = 'visible / vis', DESC = 'Makes you visible to other players'}
CMDs[#CMDs + 1] = {NAME = 'toolinvisible / toolinvis / tinvis', DESC = 'Makes you invisible to other players and able to use tools'}
CMDs[#CMDs + 1] = {NAME = 'speed / ws / walkspeed [num]', DESC = 'Change your walkspeed (default is 16)'}
CMDs[#CMDs + 1] = {NAME = 'spoofspeed / spoofws [num]', DESC = 'Spoofs your WalkSpeed on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopspeed / loopws [num]', DESC = 'Loops your walkspeed'}
CMDs[#CMDs + 1] = {NAME = 'unloopspeed / unloopws', DESC = 'Turns off loopspeed'}
CMDs[#CMDs + 1] = {NAME = 'hipheight / hheight [num]', DESC = 'Adjusts hip height'}
CMDs[#CMDs + 1] = {NAME = 'jumppower / jpower / jp [num]', DESC = 'Change a players jump height (default is 50)'}
CMDs[#CMDs + 1] = {NAME = 'spoofjumppower / spoofjp [num]', DESC = 'Spoofs your JumpPower on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopjumppower / loopjp [num]', DESC = 'Loops your jump height'}
CMDs[#CMDs + 1] = {NAME = 'unloopjumppower / unloopjp', DESC = 'Turns off loopjumppower'}
CMDs[#CMDs + 1] = {NAME = 'maxslopeangle / msa [num]', DESC = 'Adjusts MaxSlopeAngle'}
CMDs[#CMDs + 1] = {NAME = 'gravity / grav [num] (CLIENT)', DESC = 'Change your gravity'}
CMDs[#CMDs + 1] = {NAME = 'sit', DESC = 'Makes your character sit'}
CMDs[#CMDs + 1] = {NAME = 'lay / laydown', DESC = 'Makes your character lay down'}
CMDs[#CMDs + 1] = {NAME = 'sitwalk', DESC = 'Makes your character sit while still being able to walk'}
CMDs[#CMDs + 1] = {NAME = 'nosit', DESC = 'Prevents your character from sitting'}
CMDs[#CMDs + 1] = {NAME = 'unnosit', DESC = 'Disables nosit'}
CMDs[#CMDs + 1] = {NAME = 'jump', DESC = 'Makes your character jump'}
CMDs[#CMDs + 1] = {NAME = 'infinitejump / infjump', DESC = 'Allows you to jump before hitting the ground'}
CMDs[#CMDs + 1] = {NAME = 'uninfinitejump / uninfjump', DESC = 'Disables infjump'}
CMDs[#CMDs + 1] = {NAME = 'flyjump', DESC = 'Allows you to hold space to fly up'}
CMDs[#CMDs + 1] = {NAME = 'unflyjump', DESC = 'Disables flyjump'}
CMDs[#CMDs + 1] = {NAME = 'autojump / ajump', DESC = 'Automatically jumps when you run into an object'}
CMDs[#CMDs + 1] = {NAME = 'unautojump / unajump', DESC = 'Disables autojump'}
CMDs[#CMDs + 1] = {NAME = 'edgejump / ejump', DESC = 'Automatically jumps when you get to the edge of an object'}
CMDs[#CMDs + 1] = {NAME = 'unedgejump / unejump', DESC = 'Disables edgejump'}
CMDs[#CMDs + 1] = {NAME = 'platformstand / stun', DESC = 'Enables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'unplatformstand / unstun', DESC = 'Disables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'norotate / noautorotate', DESC = 'Disables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'unnorotate / autorotate', DESC = 'Enables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'enablestate [StateType]', DESC = 'Enables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'disablestate [StateType]', DESC = 'Disables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'team [team name] (CLIENT)', DESC = 'Changes your team. Sometimes fools localscripts.'}
CMDs[#CMDs + 1] = {NAME = 'nobillboardgui / nobgui / noname', DESC = 'Removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'loopnobgui / loopnoname', DESC = 'Loop removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'unloopnobgui / unloopnoname', DESC = 'Disables loopnobgui'}
CMDs[#CMDs + 1] = {NAME = 'noarms', DESC = 'Removes your arms'}
CMDs[#CMDs + 1] = {NAME = 'nolegs', DESC = 'Removes your legs'}
CMDs[#CMDs + 1] = {NAME = 'nolimbs', DESC = 'Removes your limbs'}
CMDs[#CMDs + 1] = {NAME = 'naked (CLIENT)', DESC = 'Removes your clothing'}
CMDs[#CMDs + 1] = {NAME = 'noface / removeface', DESC = 'Removes your face'}
CMDs[#CMDs + 1] = {NAME = 'blockhead', DESC = 'Turns your head into a block'}
CMDs[#CMDs + 1] = {NAME = 'blockhats', DESC = 'Turns your hats into blocks'}
CMDs[#CMDs + 1] = {NAME = 'blocktool', DESC = 'Turns the currently selected tool into a block'}
CMDs[#CMDs + 1] = {NAME = 'creeper', DESC = 'Makes you look like a creeper'}
CMDs[#CMDs + 1] = {NAME = 'drophats', DESC = 'Drops your hats'}
CMDs[#CMDs + 1] = {NAME = 'nohats / deletehats / rhats', DESC = 'Deletes your hats'}
CMDs[#CMDs + 1] = {NAME = 'hatspin / spinhats', DESC = 'Spins your characters accessories'}
CMDs[#CMDs + 1] = {NAME = 'unhatspin / unspinhats', DESC = 'Undoes spinhats'}
CMDs[#CMDs + 1] = {NAME = 'clearhats / cleanhats', DESC = 'Clears hats in the workspace'}
CMDs[#CMDs + 1] = {NAME = 'chardelete / cd [instance name]', DESC = 'Removes any part with a certain name from your character'}
CMDs[#CMDs + 1] = {NAME = 'chardeleteclass / cdc [class name]', DESC = 'Removes any part with a certain classname from your character'}
CMDs[#CMDs + 1] = {NAME = 'deletevelocity / dv / removeforces', DESC = 'Removes any velocity / force instances in your character'}
CMDs[#CMDs + 1] = {NAME = 'weaken [num]', DESC = 'Makes your character less dense'}
CMDs[#CMDs + 1] = {NAME = 'unweaken', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'strengthen [num]', DESC = 'Makes your character more dense (CustomPhysicalProperties)'}
CMDs[#CMDs + 1] = {NAME = 'unstrengthen', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'breakvelocity', DESC = 'Sets your characters velocity to 0'}
CMDs[#CMDs + 1] = {NAME = 'spin [speed]', DESC = 'Spins your character'}
CMDs[#CMDs + 1] = {NAME = 'unspin', DESC = 'Disables spin'}
CMDs[#CMDs + 1] = {NAME = 'split', DESC = 'Splits your character in half'}
CMDs[#CMDs + 1] = {NAME = 'nilchar', DESC = 'Sets your characters parent to nil'}
CMDs[#CMDs + 1] = {NAME = 'unnilchar / nonilchar', DESC = 'Sets your characters parent to workspace'}
CMDs[#CMDs + 1] = {NAME = 'noroot / removeroot / rroot', DESC = 'Removes your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'replaceroot', DESC = 'Replaces your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'clearcharappearance / clearchar / clrchar', DESC = 'Removes all accessory, shirt, pants, charactermesh, and bodycolors'}
CMDs[#CMDs + 1] = {NAME = 'tpwalk / teleportwalk [num]', DESC = 'Teleports you to your move direction'}
CMDs[#CMDs + 1] = {NAME = 'untpwalk / unteleportwalk', DESC = 'Undoes tpwalk / teleportwalk'}
CMDs[#CMDs + 1] = {NAME = 'trip', DESC = 'Makes your character fall over'}
CMDs[#CMDs + 1] = {NAME = 'wallwalk / walkonwalls', DESC = 'Walk on walls'}
CMDs[#CMDs + 1] = {NAME = 'promptr6', DESC = 'Prompts the game to switch your rig type to R6'}
CMDs[#CMDs + 1] = {NAME = 'promptr15', DESC = 'Prompts the game to switch your rig type to R15'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'animation / anim [ID] [speed]', DESC = 'Makes your character perform an animation (must be an animation on the marketplace or by roblox/stickmasterluke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'emote / em [ID] [speed]', DESC = 'Makes your character perform an emote (must be on the marketplace or by roblox/stickmasterluke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'dance', DESC = 'Makes you  d a n c e'}
CMDs[#CMDs + 1] = {NAME = 'undance', DESC = 'Stops dance animations'}
CMDs[#CMDs + 1] = {NAME = 'spasm', DESC = 'Makes you  c r a z y'}
CMDs[#CMDs + 1] = {NAME = 'unspasm', DESC = 'Stops spasm'}
CMDs[#CMDs + 1] = {NAME = 'headthrow', DESC = 'Simply makes you throw your head'}
CMDs[#CMDs + 1] = {NAME = 'noanim', DESC = 'Disables your animations'}
CMDs[#CMDs + 1] = {NAME = 'reanim', DESC = 'Restores your animations'}
CMDs[#CMDs + 1] = {NAME = 'animspeed [num]', DESC = 'Changes the speed of your current animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimation / copyanim / copyemote [player]', DESC = 'Copies someone elses animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimationid / copyanimid / copyemoteid [player]', DESC = 'Copies your animation id or someone elses to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'loopanimation / loopanim', DESC = 'Loops your current animation'}
CMDs[#CMDs + 1] = {NAME = 'stopanimations / stopanims', DESC = 'Stops running animations'}
CMDs[#CMDs + 1] = {NAME = 'refreshanimations / refreshanims', DESC = 'Refreshes animations'}
CMDs[#CMDs + 1] = {NAME = 'allowcustomanim / allowcustomanimations', DESC = 'Lets you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = 'unallowcustomanim / unallowcustomanimations', DESC = 'Doesn\'t let you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'autoclick [click delay] [release delay]', DESC = 'Automatically clicks your mouse with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautoclick / noautoclick', DESC = 'Turns off autoclick'}
CMDs[#CMDs + 1] = {NAME = 'autokeypress [key] [down delay] [up delay]', DESC = 'Automatically presses a key with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautokeypress', DESC = 'Stops autokeypress'}
CMDs[#CMDs + 1] = {NAME = 'hovername', DESC = 'Shows a players username when your mouse is hovered over them'}
CMDs[#CMDs + 1] = {NAME = 'unhovername / nohovername', DESC = 'Turns off hovername'}
CMDs[#CMDs + 1] = {NAME = 'mousesensitivity / ms [0-10]', DESC = 'Sets your mouse sensitivity (affects first person and right click drag) (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'clickdelete', DESC = 'Go to Settings > Keybinds > Add for click delete'}
CMDs[#CMDs + 1] = {NAME = 'clickteleport', DESC = 'Go to Settings > Keybinds > Add for click teleport'}
CMDs[#CMDs + 1] = {NAME = 'mouseteleport / mousetp', DESC = 'Teleports your character to your mouse. This is recommended as a keybind'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'tools', DESC = 'Copies tools from ReplicatedStorage and Lighting'}
CMDs[#CMDs + 1] = {NAME = 'notools / removetools / deletetools', DESC = 'Removes tools from character and backpack'}
CMDs[#CMDs + 1] = {NAME = 'deleteselectedtool / dst', DESC = 'Removes any currently selected tools'}
CMDs[#CMDs + 1] = {NAME = 'grabtools', DESC = 'Automatically get tools that are dropped'}
CMDs[#CMDs + 1] = {NAME = 'ungrabtools / nograbtools', DESC = 'Disables grabtools'}
CMDs[#CMDs + 1] = {NAME = 'copytools [player] (CLIENT)', DESC = 'Copies a players tools'}
CMDs[#CMDs + 1] = {NAME = 'dupetools / clonetools [num]', DESC = 'Duplicates your inventory tools a set amount of times'}
CMDs[#CMDs + 1] = {NAME = 'droptools', DESC = 'Drops your tools'}
CMDs[#CMDs + 1] = {NAME = 'droppabletools', DESC = 'Makes your tools droppable'}
CMDs[#CMDs + 1] = {NAME = 'equiptools', DESC = 'Equips every tool in your inventory at once'}
CMDs[#CMDs + 1] = {NAME = 'unequiptools', DESC = 'Unequips every tool you are currently holding at once'}
CMDs[#CMDs + 1] = {NAME = 'removespecifictool [name]', DESC = 'Automatically remove a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'unremovespecifictool [name]', DESC = 'Stops removing a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'clearremovespecifictool', DESC = 'Stop removing all specific tools from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'reach [num]', DESC = 'Increases the hitbox of your held tool'}
CMDs[#CMDs + 1] = {NAME = 'boxreach [num]', DESC = 'Increases the hitbox of your held tool in a box shape'}
CMDs[#CMDs + 1] = {NAME = 'unreach / noreach', DESC = 'Turns off reach'}
CMDs[#CMDs + 1] = {NAME = 'grippos [X Y Z]', DESC = 'Changes your current tools grip position'}
CMDs[#CMDs + 1] = {NAME = 'usetools [amount] [delay]', DESC = 'Activates all tools in your backpack at the same time'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addalias [cmd] [alias]', DESC = 'Adds an alias to a command'}
CMDs[#CMDs + 1] = {NAME = 'removealias [alias]', DESC = 'Removes a custom alias'}
CMDs[#CMDs + 1] = {NAME = 'clraliases', DESC = 'Removes all custom aliases'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addplugin / plugin [name]', DESC = 'Add a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'removeplugin / deleteplugin [name]', DESC = 'Remove a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'reloadplugin [name]', DESC = 'Reloads a plugin'}
CMDs[#CMDs + 1] = {NAME = 'addallplugins / loadallplugins', DESC = 'Adds all available plugins from the workspace folder'}
-- wait()

-- Command entries remain the original entries; favorites only change their visual order.
local commandEntryRows = {}
local commandRowsByName = {}
local commandOptions = {}
local commandOptionSeen = {}

FavSectionHeader = Instance.new("TextLabel")
FavSectionHeader.Name = "FavCmdsSectionHeader"
FavSectionHeader.Parent = CMDsF
FavSectionHeader.BackgroundColor3 = currentShade1 or Color3.fromRGB(36, 36, 37)
FavSectionHeader.BorderSizePixel = 0
FavSectionHeader.Size = UDim2.new(1, -5, 0, 18)
FavSectionHeader.Font = Enum.Font.SourceSansBold
FavSectionHeader.TextSize = 14
FavSectionHeader.Text = "Fav cmds"
FavSectionHeader.TextColor3 = Color3.new(1, 1, 1)
FavSectionHeader.TextXAlignment = Enum.TextXAlignment.Left
FavSectionHeader.ZIndex = 10
FavSectionHeader:SetAttribute("IsCommandSectionHeader", true)
table.insert(shade1, FavSectionHeader)
table.insert(text1, FavSectionHeader)

FavEmptyLabel = Instance.new("TextLabel")
FavEmptyLabel.Name = "FavCmdsEmptyState"
FavEmptyLabel.Parent = CMDsF
FavEmptyLabel.BackgroundTransparency = 1
FavEmptyLabel.BorderSizePixel = 0
FavEmptyLabel.Size = UDim2.new(1, -5, 0, 18)
FavEmptyLabel.Font = Enum.Font.SourceSansItalic
FavEmptyLabel.TextSize = 12
FavEmptyLabel.Text = "Add favorites in Settings"
FavEmptyLabel.TextColor3 = Color3.new(1, 1, 1)
FavEmptyLabel.TextXAlignment = Enum.TextXAlignment.Left
FavEmptyLabel.ZIndex = 10
FavEmptyLabel:SetAttribute("IsCommandEmptyState", true)
table.insert(text1, FavEmptyLabel)

AllCommandsHeader = Instance.new("TextLabel")
AllCommandsHeader.Name = "AllCommandsSectionHeader"
AllCommandsHeader.Parent = CMDsF
AllCommandsHeader.BackgroundColor3 = currentShade1 or Color3.fromRGB(36, 36, 37)
AllCommandsHeader.BorderSizePixel = 0
AllCommandsHeader.Size = UDim2.new(1, -5, 0, 18)
AllCommandsHeader.Font = Enum.Font.SourceSansBold
AllCommandsHeader.TextSize = 14
AllCommandsHeader.Text = "All commands"
AllCommandsHeader.TextColor3 = Color3.new(1, 1, 1)
AllCommandsHeader.TextXAlignment = Enum.TextXAlignment.Left
AllCommandsHeader.ZIndex = 10
AllCommandsHeader:SetAttribute("IsCommandSectionHeader", true)
table.insert(shade1, AllCommandsHeader)
table.insert(text1, AllCommandsHeader)
applyCommandPaletteColors()

for i = 1, #CMDs do
	local newcmd = Example:Clone()
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = CMDs[i].NAME
	newcmd.Name = "CMD"
	newcmd.Active = false
	newcmd.LayoutOrder = 1000 + i
	newcmd:SetAttribute("IsCommandEntry", true)
	newcmd:SetAttribute("CommandName", CMDs[i].NAME)
	table.insert(commandEntryRows, newcmd)
	if CMDs[i].NAME ~= "" and not commandRowsByName[CMDs[i].NAME] then
		commandRowsByName[CMDs[i].NAME] = newcmd
		if not commandOptionSeen[CMDs[i].NAME] then
			commandOptionSeen[CMDs[i].NAME] = true
			table.insert(commandOptions, {NAME = CMDs[i].NAME, DESC = CMDs[i].DESC or ""})
		end
	end
	table.insert(text1, newcmd)
	if CMDs[i].DESC ~= "" then
		newcmd:SetAttribute("Title", CMDs[i].NAME)
		newcmd:SetAttribute("Desc", CMDs[i].DESC)
	end
end

local function favoriteHas(name)
	for _, existingName in ipairs(favoriteCommands or {}) do
		if existingName == name then return true end
	end
	return false
end

local function reorderCommandEntries()
	local cleanedFavorites = {}
	local favoriteSeen = {}
	for _, name in ipairs(favoriteCommands or {}) do
		if type(name) == "string" and name ~= "" and commandRowsByName[name] and not favoriteSeen[name] then
			favoriteSeen[name] = true
			table.insert(cleanedFavorites, name)
		end
	end
	favoriteCommands = cleanedFavorites

	local nextOrder = 0
	FavSectionHeader.LayoutOrder = nextOrder
	nextOrder = nextOrder + 1
	local favoriteRowSet = {}
	for _, name in ipairs(favoriteCommands) do
		local row = commandRowsByName[name]
		if row then
			row.LayoutOrder = nextOrder
			nextOrder = nextOrder + 1
			row:SetAttribute("IsFavoriteCommand", true)
			-- Match the normal command font size; measure wrapped text so long names
			-- stay inside the list without overlapping neighboring rows.
			row.TextSize = Example.TextSize
			row.TextWrapped = true
			row.TextYAlignment = Enum.TextYAlignment.Center
			row.AutomaticSize = Enum.AutomaticSize.None
			local favoriteTextWidth = math.max(120, CMDsF.Size.X.Offset - 15)
			local favoriteTextHeight = 20
			local measureOK, textBounds = pcall(function()
				return TextService:GetTextSize(row.Text, row.TextSize, row.Font, Vector2.new(favoriteTextWidth, 10000))
			end)
			if measureOK and textBounds then
				favoriteTextHeight = math.max(20, math.ceil(textBounds.Y) + 2)
			end
			row.Size = UDim2.new(1, -15, 0, favoriteTextHeight)
			favoriteRowSet[row] = true
		end
	end
	FavEmptyLabel.LayoutOrder = nextOrder
	FavEmptyLabel.Size = UDim2.new(1, -5, 0, #favoriteCommands == 0 and 18 or 0)
	FavEmptyLabel.Visible = #favoriteCommands == 0
	nextOrder = nextOrder + 1
	AllCommandsHeader.LayoutOrder = nextOrder
	nextOrder = nextOrder + 1

	for _, row in ipairs(commandEntryRows) do
		if not favoriteRowSet[row] then
			row:SetAttribute("IsFavoriteCommand", false)
			-- Restore the original command-row styling when a favorite is removed.
			row.TextSize = Example.TextSize
			row.TextWrapped = false
			row.TextYAlignment = Example.TextYAlignment
			row.AutomaticSize = Enum.AutomaticSize.None
			row.Size = Example.Size
			row.LayoutOrder = nextOrder
			nextOrder = nextOrder + 1
		end
	end
	updateCommandCanvasSize(CMDsF)
end

local FavCmdsManagerFrame = Instance.new("Frame")
FavCmdsManagerFrame.Name = "FavCmdsManagerFrame"
FavCmdsManagerFrame.Parent = Settings
FavCmdsManagerFrame.Active = true
FavCmdsManagerFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
FavCmdsManagerFrame.BorderSizePixel = 0
FavCmdsManagerFrame.Position = UDim2.new(0, 0, 0, 200)
FavCmdsManagerFrame.Size = UDim2.new(0, 250, 0, 200)
FavCmdsManagerFrame.Visible = false
FavCmdsManagerFrame.ZIndex = 20
table.insert(shade1, FavCmdsManagerFrame)

local FavManagerTitle = Instance.new("TextLabel")
FavManagerTitle.Name = "Header"
FavManagerTitle.Parent = FavCmdsManagerFrame
FavManagerTitle.BackgroundTransparency = 1
FavManagerTitle.BorderSizePixel = 0
FavManagerTitle.Position = UDim2.new(0, 5, 0, 1)
FavManagerTitle.Size = UDim2.new(1, -10, 0, 18)
FavManagerTitle.Font = Enum.Font.SourceSans
FavManagerTitle.TextSize = 14
FavManagerTitle.Text = "Manage Fav cmds"
FavManagerTitle.TextColor3 = Color3.new(1, 1, 1)
FavManagerTitle.TextXAlignment = Enum.TextXAlignment.Left
FavManagerTitle.ZIndex = 21
table.insert(shade2, FavManagerTitle)
table.insert(text1, FavManagerTitle)

local FavManagerClose = Instance.new("TextButton")
FavManagerClose.Name = "Close"
FavManagerClose.Parent = FavCmdsManagerFrame
FavManagerClose.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FavManagerClose.BorderSizePixel = 0
FavManagerClose.Position = UDim2.new(0, 205, 0, 175)
FavManagerClose.Size = UDim2.new(0, 40, 0, 20)
FavManagerClose.Font = Enum.Font.SourceSans
FavManagerClose.TextSize = 14
FavManagerClose.Text = "Close"
FavManagerClose.TextColor3 = Color3.new(1, 1, 1)
FavManagerClose.ZIndex = 22
table.insert(shade2, FavManagerClose)
table.insert(text1, FavManagerClose)

local FavManagerHint = Instance.new("TextLabel")
FavManagerHint.Name = "Hint"
FavManagerHint.Parent = FavCmdsManagerFrame
FavManagerHint.BackgroundTransparency = 1
FavManagerHint.BorderSizePixel = 0
FavManagerHint.Position = UDim2.new(0, 5, 0, 21)
FavManagerHint.Size = UDim2.new(1, -10, 0, 17)
FavManagerHint.Font = Enum.Font.SourceSansItalic
FavManagerHint.TextSize = 11
FavManagerHint.Text = "Drag ↕ to reorder · × to remove"
FavManagerHint.TextColor3 = Color3.new(1, 1, 1)
FavManagerHint.TextXAlignment = Enum.TextXAlignment.Left
FavManagerHint.ZIndex = 21
table.insert(text1, FavManagerHint)

local FavCmdsList = Instance.new("ScrollingFrame")
FavCmdsList.Name = "FavoritesList"
FavCmdsList.Parent = FavCmdsManagerFrame
FavCmdsList.BackgroundTransparency = 1
FavCmdsList.BorderSizePixel = 0
FavCmdsList.Position = UDim2.new(0, 5, 0, 40)
FavCmdsList.Size = UDim2.new(1, -10, 0, 130)
FavCmdsList.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
FavCmdsList.ScrollBarThickness = 5
FavCmdsList.CanvasSize = UDim2.new(0, 0, 0, 0)
FavCmdsList.ZIndex = 21
table.insert(scroll, FavCmdsList)
local FavCmdsListLayout = Instance.new("UIListLayout")
FavCmdsListLayout.Parent = FavCmdsList
FavCmdsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
FavCmdsListLayout.Padding = UDim.new(0, 2)

local FavManagerEmpty = Instance.new("TextLabel")
FavManagerEmpty.Name = "EmptyState"
FavManagerEmpty.Parent = FavCmdsManagerFrame
FavManagerEmpty.BackgroundTransparency = 1
FavManagerEmpty.BorderSizePixel = 0
FavManagerEmpty.Position = UDim2.new(0, 8, 0, 94)
FavManagerEmpty.Size = UDim2.new(1, -16, 0, 22)
FavManagerEmpty.Font = Enum.Font.SourceSansItalic
FavManagerEmpty.TextSize = 13
FavManagerEmpty.Text = "No favorites yet. Tap Add."
FavManagerEmpty.TextColor3 = Color3.new(1, 1, 1)
FavManagerEmpty.TextXAlignment = Enum.TextXAlignment.Center
FavManagerEmpty.ZIndex = 22
table.insert(text1, FavManagerEmpty)

local FavManagerAdd = Instance.new("TextButton")
FavManagerAdd.Name = "AddExistingCommand"
FavManagerAdd.Parent = FavCmdsManagerFrame
FavManagerAdd.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FavManagerAdd.BorderSizePixel = 0
FavManagerAdd.Position = UDim2.new(0, 50, 0, 175)
FavManagerAdd.Size = UDim2.new(0, 150, 0, 20)
FavManagerAdd.Font = Enum.Font.SourceSans
FavManagerAdd.TextSize = 13
FavManagerAdd.Text = "+ Add existing command"
FavManagerAdd.TextColor3 = Color3.new(1, 1, 1)
FavManagerAdd.ZIndex = 21
table.insert(shade2, FavManagerAdd)
table.insert(text1, FavManagerAdd)

local FavCmdsPickerFrame = Instance.new("Frame")
FavCmdsPickerFrame.Name = "FavCmdsPickerFrame"
-- Use the same in-panel navigation as Edit Aliases and Waypoints; this is not a floating window.
FavCmdsPickerFrame.Parent = Settings
FavCmdsPickerFrame.Active = true
FavCmdsPickerFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
FavCmdsPickerFrame.BorderSizePixel = 0
FavCmdsPickerFrame.Position = UDim2.new(0, 0, 0, 200)
FavCmdsPickerFrame.Size = UDim2.new(0, 250, 0, 200)
FavCmdsPickerFrame.Visible = false
FavCmdsPickerFrame.ZIndex = 30
table.insert(shade1, FavCmdsPickerFrame)

local FavPickerTitle = Instance.new("TextLabel")
FavPickerTitle.Name = "Header"
FavPickerTitle.Parent = FavCmdsPickerFrame
FavPickerTitle.BackgroundTransparency = 1
FavPickerTitle.BorderSizePixel = 0
FavPickerTitle.Position = UDim2.new(0, 5, 0, 1)
FavPickerTitle.Size = UDim2.new(1, -10, 0, 18)
FavPickerTitle.Font = Enum.Font.SourceSans
FavPickerTitle.TextSize = 14
FavPickerTitle.Text = "Choose a command, then tap Done"
FavPickerTitle.TextColor3 = Color3.new(1, 1, 1)
FavPickerTitle.TextXAlignment = Enum.TextXAlignment.Left
FavPickerTitle.TextTruncate = Enum.TextTruncate.AtEnd
FavPickerTitle.Active = true
FavPickerTitle.ZIndex = 31
table.insert(shade2, FavPickerTitle)
table.insert(text1, FavPickerTitle)

local FavPickerClose = Instance.new("TextButton")
FavPickerClose.Name = "Done"
FavPickerClose.Parent = FavCmdsPickerFrame
FavPickerClose.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FavPickerClose.BorderSizePixel = 0
FavPickerClose.Position = UDim2.new(0, 25, 0, 175)
FavPickerClose.Size = UDim2.new(0, 90, 0, 20)
FavPickerClose.Font = Enum.Font.SourceSans
FavPickerClose.TextSize = 14
FavPickerClose.Text = "Done"
FavPickerClose.TextColor3 = Color3.new(1, 1, 1)
FavPickerClose.ZIndex = 32
table.insert(shade2, FavPickerClose)
table.insert(text1, FavPickerClose)

local FavPickerCloseAll = Instance.new("TextButton")
FavPickerCloseAll.Name = "Cancel"
FavPickerCloseAll.Parent = FavCmdsPickerFrame
FavPickerCloseAll.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FavPickerCloseAll.BorderSizePixel = 0
FavPickerCloseAll.Position = UDim2.new(0, 135, 0, 175)
FavPickerCloseAll.Size = UDim2.new(0, 90, 0, 20)
FavPickerCloseAll.Font = Enum.Font.SourceSans
FavPickerCloseAll.TextSize = 14
FavPickerCloseAll.Text = "Cancel"
FavPickerCloseAll.TextColor3 = Color3.new(1, 1, 1)
FavPickerCloseAll.ZIndex = 32
table.insert(shade2, FavPickerCloseAll)
table.insert(text1, FavPickerCloseAll)

local FavPickerSearch = Instance.new("TextBox")
FavPickerSearch.Name = "Search"
FavPickerSearch.Parent = FavCmdsPickerFrame
FavPickerSearch.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
FavPickerSearch.BorderSizePixel = 0
FavPickerSearch.Position = UDim2.new(0, 5, 0, 23)
FavPickerSearch.Size = UDim2.new(1, -10, 0, 20)
FavPickerSearch.Font = Enum.Font.SourceSans
FavPickerSearch.TextSize = 13
FavPickerSearch.Text = ""
FavPickerSearch.PlaceholderText = "Search existing commands"
FavPickerSearch.ClearTextOnFocus = false
FavPickerSearch.TextColor3 = Color3.new(1, 1, 1)
FavPickerSearch.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
FavPickerSearch.TextXAlignment = Enum.TextXAlignment.Left
FavPickerSearch.ZIndex = 31
table.insert(shade3, FavPickerSearch)
table.insert(text1, FavPickerSearch)

local FavPickerList = Instance.new("ScrollingFrame")
FavPickerList.Name = "CommandsList"
FavPickerList.Parent = FavCmdsPickerFrame
FavPickerList.BackgroundTransparency = 1
FavPickerList.BorderSizePixel = 0
FavPickerList.Position = UDim2.new(0, 5, 0, 47)
FavPickerList.Size = UDim2.new(1, -10, 0, 123)
FavPickerList.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
FavPickerList.ScrollBarThickness = 5
FavPickerList.CanvasSize = UDim2.new(0, 0, 0, 0)
FavPickerList.ZIndex = 31
table.insert(scroll, FavPickerList)
local FavPickerLayout = Instance.new("UIListLayout")
FavPickerLayout.Parent = FavPickerList
FavPickerLayout.SortOrder = Enum.SortOrder.LayoutOrder
FavPickerLayout.Padding = UDim.new(0, 1)

local favoriteRowFrames = {}
local favoritePickerRows = {}
local favoriteDragState = nil
local selectedFavoriteCommand = nil

local function removeThemeReferences(root)
	local themeLists = {shade1, shade2, shade3, text1, text2, scroll}
	for _, list in ipairs(themeLists) do
		for i = #list, 1, -1 do
			local object = list[i]
			if object == root or object:IsDescendantOf(root) then
				table.remove(list, i)
			end
		end
	end
end

local function applyFavoritePickerFilter()
	local query = string.lower(FavPickerSearch.Text or "")
	local shown = 0
	for index, row in ipairs(favoritePickerRows) do
		local name = row:GetAttribute("CommandName") or ""
		local matches = string.find(string.lower(name), query, 1, true) ~= nil
		row.Visible = matches
		if matches then
			row.LayoutOrder = shown
			shown = shown + 1
		else
			row.LayoutOrder = 10000 + index
		end
	end
	FavPickerList.CanvasSize = UDim2.new(0, 0, 0, math.max(0, FavPickerLayout.AbsoluteContentSize.Y + 2))
end

local function updateFavoritePickerSelection()
	for _, row in ipairs(favoritePickerRows) do
		local commandName = row:GetAttribute("CommandName")
		local isSelected = commandName ~= nil and commandName == selectedFavoriteCommand
		row.BackgroundColor3 = isSelected and currentShade3 or currentShade2
		local selectButton = row:FindFirstChild("Add")
		if selectButton then
			selectButton.Text = isSelected and "✓" or "+"
			selectButton.BackgroundColor3 = isSelected and currentShade2 or currentShade3
		end
	end
end

local function refreshFavoriteManagerRows()
	for _, child in ipairs(FavCmdsList:GetChildren()) do
		if child:GetAttribute("IsFavoriteManagerRow") then
			removeThemeReferences(child)
			child:Destroy()
		end
	end
	favoriteRowFrames = {}
	FavManagerEmpty.Visible = #favoriteCommands == 0

	for i, name in ipairs(favoriteCommands) do
		local row = Instance.new("Frame")
		row.Name = "FavoriteRow"
		row.Parent = FavCmdsList
		row.BackgroundColor3 = currentShade2
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, -6, 0, 23)
		row.LayoutOrder = i
		row.ZIndex = 22
		row:SetAttribute("IsFavoriteManagerRow", true)
		row:SetAttribute("CommandName", name)
		table.insert(shade2, row)

		local dragHandle = Instance.new("TextButton")
		dragHandle.Name = "DragHandle"
		dragHandle.Parent = row
		dragHandle.BackgroundColor3 = currentShade3
		dragHandle.BorderSizePixel = 0
		dragHandle.Position = UDim2.new(0, 0, 0, 0)
		dragHandle.Size = UDim2.new(0, 24, 1, 0)
		dragHandle.Font = Enum.Font.SourceSansBold
		dragHandle.TextSize = 16
		dragHandle.Text = "↕"
		dragHandle.TextColor3 = currentText1
		dragHandle.ZIndex = 23
		table.insert(shade3, dragHandle)
		table.insert(text1, dragHandle)

		local label = Instance.new("TextLabel")
		label.Name = "CommandName"
		label.Parent = row
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Position = UDim2.new(0, 28, 0, 0)
		label.Size = UDim2.new(1, -57, 1, 0)
		label.Font = Enum.Font.SourceSans
		label.TextSize = 13
		label.Text = name
		label.TextColor3 = currentText1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.ZIndex = 23
		table.insert(text1, label)

		local removeButton = Instance.new("TextButton")
		removeButton.Name = "Remove"
		removeButton.Parent = row
		removeButton.BackgroundColor3 = currentShade3
		removeButton.BorderSizePixel = 0
		removeButton.Position = UDim2.new(1, -25, 0, 1)
		removeButton.Size = UDim2.new(0, 24, 1, -2)
		removeButton.Font = Enum.Font.SourceSansBold
		removeButton.TextSize = 15
		removeButton.Text = "×"
		removeButton.TextColor3 = currentText1
		removeButton.ZIndex = 23
		table.insert(shade3, removeButton)
		table.insert(text1, removeButton)

		dragHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if favoriteDragState then return end
				favoriteDragState = {
					row = row,
					input = input.UserInputType == Enum.UserInputType.Touch and input or nil,
					startPosition = input.Position,
					active = false,
				}
				-- Prevent the scrolling list from stealing the gesture while the drag handle is held.
				FavCmdsList.ScrollingEnabled = false
			end
		end)

		removeButton.MouseButton1Click:Connect(function()
			for index = #favoriteCommands, 1, -1 do
				if favoriteCommands[index] == name then table.remove(favoriteCommands, index) end
			end
			reorderCommandEntries()
			refreshFavoriteManagerRows()
			updatesaves()
		end)

		table.insert(favoriteRowFrames, row)
	end
	FavCmdsList.CanvasSize = UDim2.new(0, 0, 0, math.max(0, FavCmdsListLayout.AbsoluteContentSize.Y + 2))
end

local function refreshFavoritePickerRows()
	for _, child in ipairs(FavPickerList:GetChildren()) do
		if child:GetAttribute("IsFavoritePickerRow") then
			removeThemeReferences(child)
			child:Destroy()
		end
	end
	favoritePickerRows = {}
	for i, command in ipairs(commandOptions) do
		if not favoriteHas(command.NAME) then
			local row = Instance.new("Frame")
			row.Name = "CommandPickerRow"
			row.Parent = FavPickerList
			row.BackgroundColor3 = currentShade2
			row.BorderSizePixel = 0
			row.Size = UDim2.new(1, -6, 0, 22)
			row.LayoutOrder = i
			row.ZIndex = 32
			row:SetAttribute("IsFavoritePickerRow", true)
			row:SetAttribute("CommandName", command.NAME)
			table.insert(shade2, row)

			local label = Instance.new("TextLabel")
			label.Name = "CommandName"
			label.Parent = row
			label.BackgroundTransparency = 1
			label.BorderSizePixel = 0
			label.Position = UDim2.new(0, 4, 0, 0)
			label.Size = UDim2.new(1, -34, 1, 0)
			label.Font = Enum.Font.SourceSans
			label.TextSize = 13
			label.Text = command.NAME
			label.TextColor3 = currentText1
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 33
			table.insert(text1, label)

			local addButton = Instance.new("TextButton")
			addButton.Name = "Add"
			addButton.Parent = row
			addButton.BackgroundColor3 = currentShade3
			addButton.BorderSizePixel = 0
			addButton.Position = UDim2.new(1, -25, 0, 1)
			addButton.Size = UDim2.new(0, 24, 1, -2)
			addButton.Font = Enum.Font.SourceSansBold
			addButton.TextSize = 15
			addButton.Text = "+"
			addButton.TextColor3 = currentText1
			addButton.ZIndex = 33
			table.insert(shade3, addButton)
			table.insert(text1, addButton)

			addButton.MouseButton1Click:Connect(function()
				-- This button selects a command; it does not commit the change until Done.
				if not commandRowsByName[command.NAME] then
					notify("Fav cmds", "This command is no longer available.", 3)
					return
				end
				if favoriteHas(command.NAME) then
					notify("Fav cmds", command.NAME .. " is already in favorites.", 3)
					selectedFavoriteCommand = nil
					updateFavoritePickerSelection()
					return
				end
				selectedFavoriteCommand = (selectedFavoriteCommand == command.NAME) and nil or command.NAME
				updateFavoritePickerSelection()
			end)
			table.insert(favoritePickerRows, row)
		end
	end
	applyFavoritePickerFilter()
	updateFavoritePickerSelection()
end

FavPickerSearch:GetPropertyChangedSignal("Text"):Connect(applyFavoritePickerFilter)

FavCmdsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	FavCmdsList.CanvasSize = UDim2.new(0, 0, 0, math.max(0, FavCmdsListLayout.AbsoluteContentSize.Y + 2))
end)
FavPickerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	FavPickerList.CanvasSize = UDim2.new(0, 0, 0, math.max(0, FavPickerLayout.AbsoluteContentSize.Y + 2))
end)

IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputChanged:Connect(function(input)
	local drag = favoriteDragState
	if not drag then return end

	local isMouseMove = drag.input == nil and input.UserInputType == Enum.UserInputType.MouseMovement
	local isTouchMove = drag.input ~= nil and input == drag.input
	if not isMouseMove and not isTouchMove then return end

	-- Ignore tiny finger jitter/taps; only begin reordering after a deliberate movement.
	if not drag.active then
		if math.abs(input.Position.Y - drag.startPosition.Y) < 7 then return end
		drag.active = true
		drag.row.BackgroundColor3 = currentShade3
	end

	-- Calculate the target from the list's content coordinates, not the rows' moving
	-- screen positions. This avoids repeated jumps as UIListLayout updates LayoutOrder.
	local listY = input.Position.Y - FavCmdsList.AbsolutePosition.Y + FavCmdsList.CanvasPosition.Y
	local rowStep = 25 -- 23px row height + 2px UIListLayout padding
	local targetIndex = math.clamp(math.floor((listY + rowStep / 2) / rowStep) + 1, 1, #favoriteRowFrames)
	local currentIndex = table.find(favoriteRowFrames, drag.row)
	if currentIndex and targetIndex and currentIndex ~= targetIndex then
		table.remove(favoriteRowFrames, currentIndex)
		table.insert(favoriteRowFrames, targetIndex, drag.row)
		for order, orderedRow in ipairs(favoriteRowFrames) do
			orderedRow.LayoutOrder = order
		end
	end
end))

IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputEnded:Connect(function(input)
	local drag = favoriteDragState
	if not drag then return end

	local isMouseEnd = drag.input == nil and input.UserInputType == Enum.UserInputType.MouseButton1
	local isTouchEnd = drag.input ~= nil and input == drag.input
	if not isMouseEnd and not isTouchEnd then return end

	favoriteDragState = nil
	FavCmdsList.ScrollingEnabled = true
	TweenService:Create(drag.row, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = currentShade2,
	}):Play()

	if drag.active then
		local orderedNames = {}
		for _, orderedRow in ipairs(favoriteRowFrames) do
			local orderedName = orderedRow:GetAttribute("CommandName")
			if orderedName then table.insert(orderedNames, orderedName) end
		end
		favoriteCommands = orderedNames
		reorderCommandEntries()
		updatesaves()
	end
end))

-- Serialize Fav cmds panel transitions. Older delayed callbacks must not hide
-- a panel after the user has already returned to another view.
local favoritePanelTransitionToken = 0
local favoritePanelState = "settings"

local function openFavManager()
	favoritePanelTransitionToken += 1
	local transitionToken = favoritePanelTransitionToken
	favoritePanelState = "manager"
	refreshFavoriteManagerRows()
	FavCmdsPickerFrame.Visible = false
	FavCmdsManagerFrame.Visible = true
	FavCmdsManagerFrame.Position = UDim2.new(0, 0, 0, 200)
	FavCmdsManagerFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	task.delay(0.5, function()
		if transitionToken ~= favoritePanelTransitionToken or favoritePanelState ~= "manager" then return end
		if FavCmdsManagerFrame.Visible then
			SettingsHolder.Visible = false
		end
	end)
end

local function closeFavManager()
	favoritePanelTransitionToken += 1
	local transitionToken = favoritePanelTransitionToken
	favoritePanelState = "settings"
	SettingsHolder.Visible = true
	FavCmdsPickerFrame.Visible = false
	FavCmdsManagerFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
	task.delay(0.52, function()
		if transitionToken ~= favoritePanelTransitionToken or favoritePanelState ~= "settings" then return end
		FavCmdsManagerFrame.Visible = false
		SettingsHolder.Visible = true
	end)
end

local function openFavPicker()
	favoritePanelTransitionToken += 1
	local transitionToken = favoritePanelTransitionToken
	favoritePanelState = "picker"
	selectedFavoriteCommand = nil
	FavPickerSearch.Text = ""
	refreshFavoritePickerRows()
	FavCmdsManagerFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
	FavCmdsPickerFrame.Position = UDim2.new(0, 0, 0, 200)
	FavCmdsPickerFrame.Visible = true
	FavCmdsPickerFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	task.delay(0.52, function()
		if transitionToken ~= favoritePanelTransitionToken or favoritePanelState ~= "picker" then return end
		if FavCmdsPickerFrame.Visible then
			FavCmdsManagerFrame.Visible = false
			SettingsHolder.Visible = false
		end
	end)
end

local function returnToFavManager()
	favoritePanelTransitionToken += 1
	local transitionToken = favoritePanelTransitionToken
	favoritePanelState = "manager"
	SettingsHolder.Visible = false
	FavCmdsManagerFrame.Visible = true
	FavCmdsManagerFrame.Position = UDim2.new(0, 0, 0, 200)
	FavCmdsManagerFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	FavCmdsPickerFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
	task.delay(0.52, function()
		if transitionToken ~= favoritePanelTransitionToken or favoritePanelState ~= "manager" then return end
		FavCmdsPickerFrame.Visible = false
		SettingsHolder.Visible = false
	end)
end

local function completeFavoritePickerSelection()
	local commandName = selectedFavoriteCommand
	if type(commandName) ~= "string" or commandName == "" then
		notify("Fav cmds", "Select a command first, then tap Done.", 3)
		return
	end

	local commandIsValid = commandRowsByName[commandName] ~= nil
	if commandIsValid then
		commandIsValid = false
		for _, command in ipairs(commandOptions) do
			if command.NAME == commandName then
				commandIsValid = true
				break
			end
		end
	end
	if not commandIsValid then
		notify("Fav cmds", "The selected command is not available.", 3)
		selectedFavoriteCommand = nil
		refreshFavoritePickerRows()
		return
	end
	if favoriteHas(commandName) then
		notify("Fav cmds", commandName .. " is already in favorites.", 3)
		selectedFavoriteCommand = nil
		refreshFavoritePickerRows()
		return
	end

	table.insert(favoriteCommands, commandName)
	reorderCommandEntries()
	refreshFavoriteManagerRows()
	updatesaves()
	selectedFavoriteCommand = nil
	returnToFavManager()
end

local function cancelFavoritePickerSelection()
	-- Cancel discards the pending selection and returns to the manager unchanged.
	selectedFavoriteCommand = nil
	returnToFavManager()
end

FavCmdsButton.MouseButton1Click:Connect(openFavManager)
FavManagerClose.MouseButton1Click:Connect(closeFavManager)
FavManagerAdd.MouseButton1Click:Connect(openFavPicker)
FavPickerClose.MouseButton1Click:Connect(completeFavoritePickerSelection)
FavPickerCloseAll.MouseButton1Click:Connect(cancelFavoritePickerSelection)

reorderCommandEntries()
refreshFavoriteManagerRows()
IndexContents("", true)

function checkTT()
	local t
	local guisAtPosition = COREGUI:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)

	for _, gui in pairs(guisAtPosition) do
		if gui.Parent == CMDsF then
			t = gui
		end
	end

	if t ~= nil and t:GetAttribute("Title") ~= nil then
		local x = IYMouse.X
		local y = IYMouse.Y
		local xP
		local yP
		if IYMouse.X > 200 then
			xP = x - 201
		else
			xP = x + 21
		end
		if IYMouse.Y > (IYMouse.ViewSizeY-96) then
			yP = y - 97
		else
			yP = y
		end
		Tooltip.Position = UDim2.new(0, xP, 0, yP)
		Description.Text = t:GetAttribute("Desc")
		if t:GetAttribute("Title") ~= nil then
			Title_3.Text = t:GetAttribute("Title")
		else
			Title_3.Text = ''
		end
		Tooltip.Visible = true
	else
		Tooltip.Visible = false
	end
end

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

function GetInTable(Table, Name)
	for i = 1, #Table do
		if Table[i] == Name then
			return i
		end
	end
	return false
end

function respawn(plr)
	if invisRunning then TurnVisible() end
    local char = plr.Character
    local hum = char:FindFirstChildWhichIsA("Humanoid")
	local archive = workspace.FallenPartsDestroyHeight
	local camType = workspace.CurrentCamera.CameraType
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.FallenPartsDestroyHeight = 0/0
    getRoot(char).Position = Vector3.yAxis * archive
	task.wait(plr:GetNetworkPing())
	workspace.FallenPartsDestroyHeight = archive
	repeat task.wait() until not char.Parent or not hum.Parent or (hum and hum.Health <= 0)
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
end

local refreshCmd = false
function refresh(plr)
	refreshCmd = true
	local root = getRoot(plr.Character)
	local pos = root.CFrame
	local pos1 = workspace.CurrentCamera.CFrame
	respawn(plr)
	task.spawn(function()
		local char = plr.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		while not humanoid do
			wait()
			humanoid = char:FindFirstChildOfClass("Humanoid")
		end
		humanoid.RootPart.CFrame, workspace.CurrentCamera.CFrame = pos, task.wait() and pos1
		refreshCmd = false
	end)
end

local lastDeath

function onDied()
	task.spawn(function()
		if pcall(function() Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') end) and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			IY_RELOAD_INSTANCE_STATE.TrackConnection(Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(Players.LocalPlayer.Character) then
					lastDeath = getRoot(Players.LocalPlayer.Character).CFrame
				end
			end))
		else
			wait(2)
			onDied()
		end
	end)
end

Clip = true
spDelay = 0.1
IY_RELOAD_INSTANCE_STATE.TrackConnection(Players.LocalPlayer.CharacterAdded:Connect(function()
	NOFLY()
	floating = false

	if not Clip then
		execCmd('clip')
	end

	repeat wait() until getRoot(Players.LocalPlayer.Character)

	pcall(function()
		if spawnpoint and not refreshCmd and spawnpos ~= nil then
			wait(spDelay)
			getRoot(Players.LocalPlayer.Character).CFrame = spawnpos
		end
	end)

	onDied()
end))

onDied()

local booly = {
    truthy = { ["true"] = true, ["t"] = true, ["1"] = true, ["yes"] = true, ["y"] = true, ["on"] = true, ["enable"] = true, ["enabled"] = true },
    falsy = { ["false"] = true, ["f"] = true, ["0"] = true, ["no"] = true, ["n"] = true, ["off"] = true, ["disable"] = true, ["disabled"] = true },
}

function parseBoolean(raw, default)
    raw = tostring(raw):lower()
    if booly.truthy[raw] then return true end
    if booly.falsy[raw] then return false end
    return default or false
end

function getstring(begin, args)
    return table.concat(args or cargs, " ", begin)
end

findCmd=function(cmd_name)
	for i,v in pairs(cmds)do
		if v.NAME:lower()==cmd_name:lower() or FindInTable(v.ALIAS,cmd_name:lower()) then
			return v
		end
	end
	return customAlias[cmd_name:lower()]
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

cmdHistory = {}
local lastCmds = {}
local historyCount = 0
local split=" "
local lastBreakTime = 0
function execCmd(cmdStr,speaker,store)
	cmdStr = cmdStr:gsub("%s+$", "")
	task.spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr, "\\\\", "%%BackSlash%%")

		local commandsToRun = splitString(cmdStr, "\\")
		for i, v in pairs(commandsToRun) do
			v = string.gsub(v, "%%BackSlash%%", "\\")
			local x, y, num = v:find("^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false

			if num then
				v = v:sub(y + 1)
				local x, y, del = v:find("^([%d%.]+)%^")
				if del then
					v = v:sub(y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x, y = v:find("^inf%^")
				if x then
					infTimes = true
					v = v:sub(y + 1)
					local x, y, del = v:find("^([%d%.]+)%^")
					if del then
						v = v:sub(y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)

			if v:sub(1, 1) == "!" then
				local chunks = splitString(v:sub(2), split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end

			local args = splitString(v, split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args, 1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end

				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and rawCmdStr:sub(1, 11) ~= "lastcommand" and rawCmdStr:sub(1, 7) ~= "lastcmd" then
							table.insert(cmdHistory, 1, rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end

					lastCmds[cmdName] = v
				end

				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1, num do
						if lastBreakTime > cmdStartTime then break end
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
							notify("Command Error: " .. cmdName, "Check console")
						end
						if success and type(err) == "string" and not table.find(args, "nonotify") then
							notify("Command: " .. cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end

function addcmd(name,alias,func,plgn)
	cmds[#cmds+1]=
		{
			NAME=name;
			ALIAS=alias or {};
			FUNC=func;
			PLUGIN=plgn;
		}
end

function removecmd(cmd)
	if cmd ~= " " then
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS,cmd) then
				table.remove(cmds, i)
				for _, c in pairs(CMDsF:GetChildren()) do
					if (c:IsA("TextLabel") or c:IsA("TextButton")) and (string.find(c.Text, "^"..cmd.."$") or string.find(c.Text, "^"..cmd.." ") or string.find(c.Text, " "..cmd.."$") or string.find(c.Text, " "..cmd.." ")) then
						c.TextTransparency = 0.7
					end
				end
			end
		end
	end
end

function overridecmd(name, func)
	local cmd = findCmd(name)
	if cmd and cmd.FUNC then cmd.FUNC = func end
end

function addbind(cmd,key,iskeyup,toggle)
	if toggle then
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
				TOGGLE = toggle;
			}
	else
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
			}
	end
end

function addcmdtext(text,name,desc)
	local newcmd = Example:Clone()
	local tooltipText = tostring(text)
	local tooltipDesc = tostring(desc)
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = text
	newcmd.Name = 'PLUGIN_'..name
	newcmd.Active = false
	table.insert(text1,newcmd)
	if desc and desc ~= '' then
		newcmd:SetAttribute("Title", tooltipText)
		newcmd:SetAttribute("Desc", tooltipDesc)
	end
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(IYMouse.X, IYMouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
	if player.DisplayName ~= player.Name then
		return string.format("%s (%s)", player.Name, player.DisplayName)
	end
	return player.Name
end

getprfx=function(strn)
	if strn:sub(1,string.len(prefix))==prefix then return{'cmd',string.len(prefix)+1}
	end return
end

function do_exec(str, plr)
	str = str:gsub('/e ', '')
	local t = getprfx(str)
	if not t then return end
	str = str:sub(t[2])
	if t[1]=='cmd' then
		execCmd(str, plr, true)
		IndexContents('',true,false,true)
		CMDsF.CanvasPosition = canvasPos
	end
end

lastTextBoxString,lastTextBoxCon,lastEnteredString = nil,nil,nil

IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.TextBoxFocused:Connect(function(obj)
	if lastTextBoxCon then lastTextBoxCon:Disconnect() end
	if obj == Cmdbar then lastTextBoxString = nil return end
	lastTextBoxString = obj.Text
	lastTextBoxCon = IY_RELOAD_INSTANCE_STATE.TrackConnection(obj:GetPropertyChangedSignal("Text"):Connect(function()
		if not (UserInputService:IsKeyDown(Enum.KeyCode.Return) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadEnter)) then
			lastTextBoxString = obj.Text
		end
	end))
end))

IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		if Cmdbar and Cmdbar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Up then
				historyCount = historyCount + 1
				if historyCount > #cmdHistory then historyCount = #cmdHistory end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyCount = historyCount - 1
				if historyCount < 0 then historyCount = 0 end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			lastEnteredString = lastTextBoxString
		end
	end
end))

IY_RELOAD_INSTANCE_STATE.TrackConnection(Players.LocalPlayer.Chatted:Connect(function()
	wait()
	if lastEnteredString then
		local message = lastEnteredString
		lastEnteredString = nil
		do_exec(message, Players.LocalPlayer)
	end
end))

Cmdbar.PlaceholderText = "Command Bar"
Cmdbar:GetPropertyChangedSignal("Text"):Connect(function()
	if Cmdbar:IsFocused() then
		IndexContents(Cmdbar.Text,true,true)
	end
end)

local tabComplete = nil
tabAllowed = true
Cmdbar.FocusLost:Connect(function(enterpressed)
	if enterpressed then
		local cmdbarText = Cmdbar.Text:gsub("^"..prefix,"")
		execCmd(cmdbarText,Players.LocalPlayer,true)
	end
	if tabComplete then tabComplete:Disconnect() end
	wait()
	if not Cmdbar:IsFocused() then
		Cmdbar.Text = ""
		IndexContents('',true,false,false)
		if SettingsOpen == true then
			wait(0.2)
			Settings:TweenPosition(UDim2.new(0, 0, 0, 20), "InOut", "Quart", 0.2, true, nil)
			CMDsF.Visible = false
			setSettingsBackdrop(true)
		end
		if not SettingsOpen and not StayOpen then
			scheduleHolderAutoHide(autoHideDelay)
		end
	end
	CMDsF.CanvasPosition = canvasPos
end)

Cmdbar.Focused:Connect(function()
	historyCount = 0
	canvasPos = CMDsF.CanvasPosition
	if SettingsOpen == true then
		-- Settings owns the panel while open; never restore the command-list backdrop from focus events.
		setSettingsBackdrop(true)
		CMDsF.Visible = false
		Settings.Size = UDim2.new(0, 250, 0, 200)
		Settings:TweenPosition(UDim2.new(0, 0, 0, 20), "InOut", "Quart", 0.2, true, nil)
		return
	end
	tabComplete = UserInputService.InputBegan:Connect(function(input,gameProcessed)
		if Cmdbar:IsFocused() then
			if tabAllowed == true and input.KeyCode == Enum.KeyCode.Tab and topCommand ~= nil then
				autoComplete(topCommand)
			end
		else
			tabComplete:Disconnect()
		end
	end)
end)

ESPenabled = false
CHMSenabled = false

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ESP(plr, logic)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					if logic == true then
						a.Color = BrickColor.new(plr.TeamColor == Players.LocalPlayer.TeamColor and "Bright green" or "Bright red")
					else
						a.Color = plr.TeamColor
					end
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			local addedFunc
			local teamChange
			local CHMSremoved
			addedFunc = plr.CharacterAdded:Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function lcLoop()
					if COREGUI:FindFirstChild(plr.Name..'_LC') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						lcLoopFunc:Disconnect()
					end
				end
				lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
			end
		end
	end)
end

local bindsGUI = KeybindEditor
local awaitingInput = false
local keySelected = false

function refreshbinds()
	if Holder_2 then
		Holder_2:ClearAllChildren()
		Holder_2.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #binds do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newbind = Example_2:Clone()
			newbind.Parent = Holder_2
			newbind.Visible = true
			newbind.Position = UDim2.new(0,0,0, Position + 5)
			table.insert(shade2,newbind)
			table.insert(shade2,newbind.Text)
			table.insert(text1,newbind.Text)
			table.insert(shade3,newbind.Text.Delete)
			table.insert(text2,newbind.Text.Delete)
			local input = tostring(binds[i].KEY)
			local key
			if input == 'RightClick' or input == 'LeftClick' then
				key = input
			else
				key = input:sub(14)
			end
			if binds[i].TOGGLE then
				newbind.Text.Text = key.." > "..binds[i].COMMAND.." / "..binds[i].TOGGLE
			else
				newbind.Text.Text = key.." > "..binds[i].COMMAND.."  "..(binds[i].ISKEYUP and "(keyup)" or "(keydown)")
			end
			Holder_2.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newbind.Text.Delete.MouseButton1Click:Connect(function()
				unkeybind(binds[i].COMMAND,binds[i].KEY)
			end)
		end
	end
end

refreshbinds()

toggleOn = {}

function unkeybind(cmd,key)
	for i = #binds,1,-1 do
		if binds[i].COMMAND == cmd and binds[i].KEY == key then
			toggleOn[binds[i]] = nil
			table.remove(binds, i)
		end
	end
	refreshbinds()
	updatesaves()
	if key == 'RightClick' or key == 'LeftClick' then
		notify('Keybinds Updated','Unbinded '..key..' from '..cmd)
	else
		notify('Keybinds Updated','Unbinded '..key:sub(14)..' from '..cmd)
	end
end

PositionsFrame.Delete.MouseButton1Click:Connect(openWaypointClearConfirmation)
AddWaypointButton.MouseButton1Click:Connect(openWaypointAddPanel)

local function waypointNameIsTaken(candidateName)
	local target = string.lower(tostring(candidateName or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	for _, waypointList in ipairs({WayPoints or {}, pWayPoints or {}}) do
		for _, existing in ipairs(waypointList) do
			if type(existing) == "table" then
				local existingName = string.lower(tostring(existing.NAME or ""):gsub("^%s+", ""):gsub("%s+$", ""))
				if existingName == target then return true end
			end
		end
	end
	return false
end

local function nextDefaultWaypointName()
	local alphabet = "abcdefghijklmnopqrstuvwxyz"
	local index = 1
	while true do
		local number = index
		local name = ""
		while number > 0 do
			local letterIndex = ((number - 1) % #alphabet) + 1
			name = alphabet:sub(letterIndex, letterIndex) .. name
			number = math.floor((number - 1) / #alphabet)
		end
		if not waypointNameIsTaken(name) then return name end
		index += 1
	end
end

WaypointAddCancel.MouseButton1Click:Connect(function()
	if waypointPanelState ~= "add" then return end
	WaypointNameInput:ReleaseFocus()
	WaypointNameInput.Text = ""
	returnToWaypointsPanel()
end)

WaypointAddDone.MouseButton1Click:Connect(function()
	if waypointPanelState ~= "add" then return end
	local WPName = tostring(WaypointNameInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if WPName == "" then
		WPName = nextDefaultWaypointName()
	end
	local nameLength = utf8.len(WPName)
	if not nameLength or nameLength > 64 or WPName:find("%c") then
		notify("Waypoint Error", "Name must be 1–64 characters and cannot contain control characters.", 4)
		return
	end

	local nameLower = string.lower(WPName)
	for _, existing in ipairs(WayPoints or {}) do
		if type(existing) == "table" and string.lower(tostring(existing.NAME or ""):gsub("^%s+", ""):gsub("%s+$", "")) == nameLower then
			notify("Waypoint Error", "A waypoint with that name already exists.", 4)
			return
		end
	end
	for _, existing in ipairs(pWayPoints or {}) do
		if type(existing) == "table" and string.lower(tostring(existing.NAME or ""):gsub("^%s+", ""):gsub("%s+$", "")) == nameLower then
			notify("Waypoint Error", "A waypoint with that name already exists.", 4)
			return
		end
	end

	local characterRoot = getRoot(Players.LocalPlayer.Character)
	if not characterRoot then
		notify("Waypoint Error", "Cannot save a waypoint because your character is not ready.", 4)
		return
	end

	local coordinate = {math.floor(characterRoot.Position.X), math.floor(characterRoot.Position.Y), math.floor(characterRoot.Position.Z)}
	WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {coordinate[1], coordinate[2], coordinate[3]}, GAME = PlaceId}
	if AllWaypoints ~= nil then
		AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {coordinate[1], coordinate[2], coordinate[3]}, GAME = PlaceId}
	end
	refreshwaypoints()
	updatesaves()
	WaypointNameInput:ReleaseFocus()
	WaypointNameInput.Text = ""
	returnToWaypointsPanel()
	notify("Modified Waypoints", "Created waypoint: " .. WPName, 4)
end)

WaypointClearConfirmButton.MouseButton1Click:Connect(function()
	if waypointPanelState ~= "clearConfirm" then return end
	execCmd('cpos')
	returnToWaypointsPanel()
end)

WaypointClearCancelButton.MouseButton1Click:Connect(function()
	if waypointPanelState ~= "clearConfirm" then return end
	returnToWaypointsPanel()
end)

-- Independent Waypoint Hover windows with unrestricted movement and saved positions.
local waypointHoverWindows = {}
local waypointHoverWindowCounter = 0
local waypointHoverWindowZIndex = 80
local activeWaypointHoverDragState = nil
local waypointHoverWindowSize = Vector2.new(66, 38)
local waypointHoverWindowGap = 8

local function normalizeWaypointHoverKey(name)
	local normalized = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	return string.lower(normalized)
end

-- Waypoint gestures: with BackTP enabled, a single tap defers Goto until the double-tap window expires; a quick second tap performs Return only. Movement = Drag.
-- Keep the Return logic grouped in one namespaced table.
IY_CRUZAN_WAYPOINT_RETURN = {
    DOUBLE_TAP_SECONDS = 0.4,
    DRAG_TOUCH_THRESHOLD = 8,
    DRAG_MOUSE_THRESHOLD = 5,
    state = nil,
    generation = 0,
    pendingGotoGeneration = nil,
    pendingReturnGeneration = nil,
    lastToggleAt = nil,
    humanoidConnection = nil,
}

function IY_CRUZAN_WAYPOINT_RETURN.getDestinationCFrame(name)
	local key = normalizeWaypointHoverKey(name)
	if key == "" then return nil end
	local destination = nil
	for _, waypoint in ipairs(WayPoints or {}) do
		if normalizeWaypointHoverKey(waypoint.NAME) == key and type(waypoint.COORD) == "table" then
			local x, y, z = tonumber(waypoint.COORD[1]), tonumber(waypoint.COORD[2]), tonumber(waypoint.COORD[3])
			if x and y and z then destination = CFrame.new(x, y, z) end
		end
	end
	for _, waypoint in ipairs(pWayPoints or {}) do
		if normalizeWaypointHoverKey(waypoint.NAME) == key and type(waypoint.COORD) == "table" then
			local part = waypoint.COORD[1]
			local ok, partPosition = pcall(function() return part.Position end)
			if ok and partPosition then destination = CFrame.new(partPosition) end
		end
	end
	return destination
end

function IY_CRUZAN_WAYPOINT_RETURN.getValidState()
	local saved = IY_CRUZAN_WAYPOINT_RETURN.state
	if not saved then return nil end
	local player = Players.LocalPlayer
	local character = player and player.Character
	local root = nil
	local rootOk = pcall(function()
		if character then root = getRoot(character) end
	end)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local valid = rootOk and character == saved.character and root == saved.root
		and root ~= nil and root.Parent ~= nil
		and humanoid ~= nil and humanoid.Health > 0
		and game.PlaceId == saved.placeId and game.JobId == saved.jobId
	if not valid then
		if IY_CRUZAN_WAYPOINT_RETURN.state == saved then
			IY_CRUZAN_WAYPOINT_RETURN.state = nil
			IY_CRUZAN_WAYPOINT_RETURN.generation += 1
		end
		return nil
	end
	return saved
end

function IY_CRUZAN_WAYPOINT_RETURN.refreshIndicators()
	-- Return availability is no longer indicated by changing Waypoint window borders.
	for _, windowState in pairs(waypointHoverWindows) do
		local frame = windowState.frame
		if frame and frame.Parent then
			frame.BorderColor3 = currentShade3 or Color3.fromRGB(78, 78, 79)
		end
	end
end

function IY_CRUZAN_WAYPOINT_RETURN.clear()
	IY_CRUZAN_WAYPOINT_RETURN.state = nil
	IY_CRUZAN_WAYPOINT_RETURN.generation += 1
	IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration = nil
	IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration = nil
	for _, windowState in pairs(waypointHoverWindows) do
		windowState.lastTapAt = nil
		windowState.lastTapGeneration = nil
	end
	IY_CRUZAN_WAYPOINT_RETURN.refreshIndicators()
end

local function updateWaypointBackTPToggleVisual()
	local checkmark = WaypointBackTPToggle and WaypointBackTPToggle:FindFirstChild("Checkmark")
	if not checkmark then return end
	local enabled = waypointBackTPEnabled == true
	checkmark.BackgroundTransparency = enabled and 0 or 1
	checkmark.Text = enabled and "✓" or ""
	checkmark.TextColor3 = Color3.new(1, 1, 1)
	checkmark.Font = Enum.Font.SourceSansBold
	checkmark.TextSize = 13
end

updateWaypointBackTPToggleVisual()
WaypointBackTPToggle.MouseButton1Click:Connect(function()
	local now = os.clock()
	if IY_CRUZAN_WAYPOINT_RETURN.lastToggleAt and now - IY_CRUZAN_WAYPOINT_RETURN.lastToggleAt < 0.15 then return end
	IY_CRUZAN_WAYPOINT_RETURN.lastToggleAt = now
	waypointBackTPEnabled = not waypointBackTPEnabled
	if not waypointBackTPEnabled then IY_CRUZAN_WAYPOINT_RETURN.clear() end
	for _, openState in pairs(waypointHoverWindows) do
		openState.lastTapAt = nil
		openState.lastTapGeneration = nil
	end
	updateWaypointBackTPToggleVisual()
	if type(updatesaves) == "function" then updatesaves() end
end)

function IY_CRUZAN_WAYPOINT_RETURN.performReturn()
	if waypointBackTPEnabled ~= true then return false end
	local saved = IY_CRUZAN_WAYPOINT_RETURN.getValidState()
	if not saved then
		IY_CRUZAN_WAYPOINT_RETURN.refreshIndicators()
		return false
	end
	local setOk = pcall(function()
		saved.root.CFrame = saved.cframe
	end)
	local verifyOk, distance = pcall(function()
		return (saved.root.Position - saved.cframe.Position).Magnitude
	end)
	if setOk and verifyOk and distance <= 3 then
		if IY_CRUZAN_WAYPOINT_RETURN.state == saved then
			IY_CRUZAN_WAYPOINT_RETURN.state = nil
			IY_CRUZAN_WAYPOINT_RETURN.generation += 1
		end
		IY_CRUZAN_WAYPOINT_RETURN.refreshIndicators()
		return true
	end
	return false
end

function IY_CRUZAN_WAYPOINT_RETURN.executeGoto(state)
	if not state or not state.waypointName or state.waypointName == "" then return nil end
	if waypointHoverWindows[state.key] ~= state then return nil end
	local player = Players.LocalPlayer
	local character = player and player.Character
	local root = nil
	pcall(function() if character then root = getRoot(character) end end)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local destination = IY_CRUZAN_WAYPOINT_RETURN.getDestinationCFrame(state.waypointName)
	local originCFrame = root and root.Parent and root.CFrame or nil
	local shouldCaptureReturn = waypointBackTPEnabled == true and originCFrame ~= nil and destination ~= nil
		and humanoid ~= nil and humanoid.Health > 0
		and (originCFrame.Position - destination.Position).Magnitude > 1
	local generation = nil
	if shouldCaptureReturn then
		IY_CRUZAN_WAYPOINT_RETURN.generation += 1
		generation = IY_CRUZAN_WAYPOINT_RETURN.generation
		IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration = generation
		IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration = nil
	end
	local commandOk = pcall(execCmd, "loadpos " .. state.waypointName)
	if not commandOk then
		if IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration == generation then
			IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration = nil
		end
		if IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration == generation then
			IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration = nil
		end
		return nil
	end
	if not shouldCaptureReturn then return generation end
	task.delay(0.1, function()
		if generation ~= IY_CRUZAN_WAYPOINT_RETURN.generation then
			if IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration == generation then
				IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration = nil
			end
			if IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration == generation then
				IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration = nil
			end
			return
		end
		local currentCharacter = player and player.Character
		local currentRoot = nil
		pcall(function() if currentCharacter then currentRoot = getRoot(currentCharacter) end end)
		local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
		local reached = false
		if currentCharacter == character and currentRoot == root and currentRoot and currentRoot.Parent
			and currentHumanoid and currentHumanoid.Health > 0
			and game.PlaceId == PlaceId and game.JobId == JobId then
			local ok, distance = pcall(function() return (currentRoot.Position - destination.Position).Magnitude end)
			reached = ok and distance <= 3
		end
		if IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration == generation then
			IY_CRUZAN_WAYPOINT_RETURN.pendingGotoGeneration = nil
		end
		if reached and generation == IY_CRUZAN_WAYPOINT_RETURN.generation and waypointBackTPEnabled == true then
			IY_CRUZAN_WAYPOINT_RETURN.state = {
				cframe = originCFrame,
				character = character,
				root = root,
				placeId = game.PlaceId,
				jobId = game.JobId,
			}
			IY_CRUZAN_WAYPOINT_RETURN.refreshIndicators()
			if IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration == generation then
				IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration = nil
				IY_CRUZAN_WAYPOINT_RETURN.performReturn()
			end
		else
			if IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration == generation then
				IY_CRUZAN_WAYPOINT_RETURN.pendingReturnGeneration = nil
			end
			if state.lastTapGeneration == generation then
				state.lastTapAt = nil
				state.lastTapGeneration = nil
			end
		end
	end)
	return generation
end

function IY_CRUZAN_WAYPOINT_RETURN.bindHumanoid(character)
	if IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection then
		pcall(function() IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection:Disconnect() end)
		IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection = nil
	end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection = humanoid.Died:Connect(IY_CRUZAN_WAYPOINT_RETURN.clear)
		IY_RELOAD_INSTANCE_STATE.TrackConnection(IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection)
	end
end

-- Register optional character/teleport events defensively. A missing event or unavailable
-- connection helper must not abort the entire script during startup.
pcall(function()
	local player = Players and Players.LocalPlayer
	if not player then return end

	local function safeTrack(signal, callback)
		local connectOk, connection = pcall(function()
			if not signal then return nil end
			return signal:Connect(callback)
		end)
		if connectOk and connection then
			pcall(function()
				if IY_RELOAD_INSTANCE_STATE and type(IY_RELOAD_INSTANCE_STATE.TrackConnection) == "function" then
					IY_RELOAD_INSTANCE_STATE.TrackConnection(connection)
				end
			end)
		end
	end

	safeTrack(player.CharacterRemoving, function()
		pcall(IY_CRUZAN_WAYPOINT_RETURN.clear)
		if IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection then
			pcall(function() IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection:Disconnect() end)
			IY_CRUZAN_WAYPOINT_RETURN.humanoidConnection = nil
		end
	end)

	safeTrack(player.CharacterAdded, function(character)
		pcall(IY_CRUZAN_WAYPOINT_RETURN.clear)
		pcall(function()
			task.spawn(function()
				local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
				if Players.LocalPlayer == player and player.Character == character and humanoid then
					IY_CRUZAN_WAYPOINT_RETURN.bindHumanoid(character)
				end
			end)
		end)
	end)

	safeTrack(player.OnTeleport, function()
		pcall(IY_CRUZAN_WAYPOINT_RETURN.clear)
	end)

	if player.Character then
		pcall(IY_CRUZAN_WAYPOINT_RETURN.bindHumanoid, player.Character)
	end
end)

local function getWaypointHoverBounds(frame)
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local topLeftInset, bottomRightInset = Vector2.new(0, 0), Vector2.new(0, 0)
	local insetOk, insetTop, insetBottom = pcall(function()
		return GuiService:GetGuiInset()
	end)
	if insetOk and insetTop and insetBottom then
		topLeftInset, bottomRightInset = insetTop, insetBottom
	end

	local rootOrigin = Vector2.new(0, 0)
	if PARENT and PARENT:IsA("ScreenGui") then
		rootOrigin = PARENT.IgnoreGuiInset and Vector2.new(0, 0) or topLeftInset
	elseif PARENT and PARENT:IsA("GuiObject") then
		rootOrigin = PARENT.AbsolutePosition
	end

	local width = frame and frame.Size.X.Offset or waypointHoverWindowSize.X
	local height = frame and frame.Size.Y.Offset or waypointHoverWindowSize.Y
	local minX = topLeftInset.X - rootOrigin.X
	local minY = topLeftInset.Y - rootOrigin.Y
	local maxX = viewport.X - bottomRightInset.X - rootOrigin.X - width
	local maxY = viewport.Y - bottomRightInset.Y - rootOrigin.Y - height
	local availableWidth = math.max(1, viewport.X - topLeftInset.X - bottomRightInset.X)
	local availableHeight = math.max(1, viewport.Y - topLeftInset.Y - bottomRightInset.Y)
	if maxX < minX then maxX = minX end
	if maxY < minY then maxY = minY end
	return minX, minY, maxX, maxY, availableWidth, availableHeight
end

local function normalizeWaypointHoverPosition(x, y)
	return math.floor((tonumber(x) or 0) + 0.5), math.floor((tonumber(y) or 0) + 0.5)
end

local function removeWaypointHoverStyleEntry(list, item)
	for index = #list, 1, -1 do
		if list[index] == item then table.remove(list, index) end
	end
end

local function persistWaypointHoverPosition(state, forceSave)
	if not state or not state.frame or not state.frame.Parent then return false end
	local position = state.frame.Position
	local x, y = normalizeWaypointHoverPosition(position.X.Offset, position.Y.Offset)
	state.frame.Position = UDim2.new(0, x, 0, y)
	local previous = waypointHoverPositions[state.key]
	local changed = not previous or previous.x ~= x or previous.y ~= y
	if changed then waypointHoverPositions[state.key] = {x = x, y = y} end
	if (changed or forceSave) and type(updatesaves) == "function" then updatesaves() end
	return changed
end

local function disconnectWaypointHoverState(state)
	if not state then return end
	if activeWaypointHoverDragState == state then activeWaypointHoverDragState = nil end
	state.inputToken = (state.inputToken or 0) + 1
	state.dragCandidate = nil
	state.dragInput = nil
	state.dragging = false
	if state.endConnection then
		pcall(function() state.endConnection:Disconnect() end)
		state.endConnection = nil
	end
	for _, connection in ipairs(state.connections or {}) do
		pcall(function() connection:Disconnect() end)
	end
	state.connections = {}
end

local function bringWaypointHoverToFront(state)
	if not state or not state.frame or not state.frame.Parent then return end
	waypointHoverWindowZIndex = math.max(waypointHoverWindowZIndex + 10, (state.frame.ZIndex or 80) + 10)
	local baseZIndex = waypointHoverWindowZIndex
	state.frame.ZIndex = baseZIndex
	if state.header then state.header.ZIndex = baseZIndex + 1 end
	if state.gotoButton then state.gotoButton.ZIndex = baseZIndex + 1 end
	if state.closeButton then state.closeButton.ZIndex = baseZIndex + 3 end
end

local function removeWaypointHoverWindow(state, savePosition)
	if not state then return end
	if savePosition then persistWaypointHoverPosition(state, true) end
	disconnectWaypointHoverState(state)
	removeWaypointHoverStyleEntry(shade1, state.frame)
	removeWaypointHoverStyleEntry(shade2, state.closeButton)
	removeWaypointHoverStyleEntry(shade2, state.gotoButton)
	removeWaypointHoverStyleEntry(text1, state.closeButton)
	removeWaypointHoverStyleEntry(text1, state.gotoButton)
	removeWaypointHoverStyleEntry(waypointHoverFrames, state.frame)
	if waypointHoverWindows[state.key] == state then waypointHoverWindows[state.key] = nil end
	if state.frame and state.frame.Parent then state.frame:Destroy() end
end

local function waypointHoverRectsOverlap(x1, y1, width1, height1, x2, y2, width2, height2)
	return not (x1 + width1 + waypointHoverWindowGap <= x2
		or x2 + width2 + waypointHoverWindowGap <= x1
		or y1 + height1 + waypointHoverWindowGap <= y2
		or y2 + height2 + waypointHoverWindowGap <= y1)
end

local function findDefaultWaypointHoverPosition(frame)
	local minX, minY, maxX = getWaypointHoverBounds(frame)
	local baseX = maxX - 12
	local baseY = minY + 45
	local selectedX, selectedY = normalizeWaypointHoverPosition(baseX, baseY)
	local width, height = frame.Size.X.Offset, frame.Size.Y.Offset
	for attempt = 0, 23 do
		local candidateX = baseX - ((attempt % 3) * (width + waypointHoverWindowGap))
		local candidateY = baseY + (math.floor(attempt / 3) * (height + waypointHoverWindowGap))
		candidateX, candidateY = normalizeWaypointHoverPosition(candidateX, candidateY)
		local overlaps = false
		for _, otherState in pairs(waypointHoverWindows) do
			if otherState.frame and otherState.frame.Visible and otherState.frame.Parent then
				local otherPosition = otherState.frame.Position
				local otherSize = otherState.frame.Size
				if waypointHoverRectsOverlap(candidateX, candidateY, width, height,
					otherPosition.X.Offset, otherPosition.Y.Offset, otherSize.X.Offset, otherSize.Y.Offset) then
					overlaps = true
					break
				end
			end
		end
		selectedX, selectedY = candidateX, candidateY
		if not overlaps then return candidateX, candidateY end
	end
	return selectedX, selectedY
end

local function registerWaypointHoverStyle(state)
	table.insert(shade1, state.frame)
	table.insert(shade2, state.closeButton)
	table.insert(shade2, state.gotoButton)
	table.insert(text1, state.closeButton)
	table.insert(text1, state.gotoButton)
end

local function createWaypointHoverWindow(name, key)
	local frame = WaypointHoverFrame:Clone()
	local header = frame:FindFirstChild("Header")
	local closeButton = frame:FindFirstChild("Close")
	local gotoButton = frame:FindFirstChild("GotoWaypoint")
	if not closeButton or not gotoButton then
		frame:Destroy()
		return nil
	end
	if header then
		header.Visible = false
		header.Text = ""
	end

	waypointHoverWindowCounter += 1
	local safeName = tostring(name):gsub("[^%w_%-]", "_")
	frame.Name = "WaypointHover_" .. safeName .. "_" .. tostring(waypointHoverWindowCounter)
	frame.AnchorPoint = Vector2.new(0, 0)
	frame.Size = UDim2.new(0, waypointHoverWindowSize.X, 0, waypointHoverWindowSize.Y)
	frame.Visible = false
	frame.ZIndex = waypointHoverWindowZIndex
	gotoButton.Position = UDim2.new(0, 0, 0, 0)
	gotoButton.Size = UDim2.new(1, 0, 1, 0)
	gotoButton.Text = name
	gotoButton.Font = Enum.Font.SourceSansBold
	gotoButton.TextSize = 16
	gotoButton.TextScaled = true
	gotoButton.AutoButtonColor = false
	gotoButton.ZIndex = frame.ZIndex + 1
	gotoButton.TextXAlignment = Enum.TextXAlignment.Center
	gotoButton.TextYAlignment = Enum.TextYAlignment.Center
	closeButton.Parent = frame
	closeButton.BackgroundTransparency = 1
	closeButton.BorderSizePixel = 0
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -17, 0, 0)
	closeButton.Size = UDim2.new(0, 17, 0, 17)
	closeButton.ZIndex = frame.ZIndex + 3
	closeButton.TextSize = 14
	frame.Parent = PARENT
	frame.BorderColor3 = currentShade3 or Color3.fromRGB(78, 78, 79)
	table.insert(waypointHoverFrames, frame)

	local state = {
		key = key,
		frame = frame,
		header = header,
		closeButton = closeButton,
		gotoButton = gotoButton,
		waypointName = name,
		connections = {},
		dragging = false,
		dragCandidate = nil,
		dragInput = nil,
		dragStart = nil,
		startPosition = nil,
		inputToken = 0,
		dragMoved = false,
		endConnection = nil,
		lastTapAt = nil,
		lastTapGeneration = nil,
		tapToken = 0,
	}
	registerWaypointHoverStyle(state)

	state.connections[#state.connections + 1] = closeButton.MouseButton1Click:Connect(function()
		removeWaypointHoverWindow(state, true)
	end)
	local function finishWaypointHoverPress(input)
		if state.dragCandidate ~= input then return end
		local wasDragging = state.dragging
		state.dragging = false
		state.dragCandidate = nil
		state.dragStart = nil
		state.startPosition = nil
		state.dragMoved = false
		state.dragInput = nil
		if activeWaypointHoverDragState == state then activeWaypointHoverDragState = nil end
		if state.endConnection then
			pcall(function() state.endConnection:Disconnect() end)
			state.endConnection = nil
		end
		if wasDragging then
			state.tapToken = (state.tapToken or 0) + 1
			state.lastTapAt = nil
			state.lastTapGeneration = nil
			persistWaypointHoverPosition(state, true)
		elseif waypointBackTPEnabled == true then
			local now = os.clock()
			local doubleTapWindow = IY_CRUZAN_WAYPOINT_RETURN.DOUBLE_TAP_SECONDS
			local previousTapAt = state.lastTapAt
			local isDoubleTap = previousTapAt ~= nil and now - previousTapAt <= doubleTapWindow
			if previousTapAt ~= nil and not isDoubleTap then
				-- The previous tap is outside the double-tap window. If its delayed
				-- callback has not run yet, commit that single-tap Goto before queuing this tap.
				state.tapToken = (state.tapToken or 0) + 1
				state.lastTapAt = nil
				state.lastTapGeneration = nil
				IY_CRUZAN_WAYPOINT_RETURN.executeGoto(state)
			end
			if isDoubleTap then
				-- Cancel the deferred Goto from the first tap. A double tap must only
				-- return to the previous origin, never visit the selected Waypoint first.
				state.tapToken = (state.tapToken or 0) + 1
				state.lastTapAt = nil
				state.lastTapGeneration = nil
				IY_CRUZAN_WAYPOINT_RETURN.performReturn()
			else
				-- Wait out the double-tap window before performing a single-click Goto.
				-- If a second tap arrives, it invalidates this token and performs Return only.
				state.lastTapAt = now
				state.lastTapGeneration = nil
				state.tapToken = (state.tapToken or 0) + 1
				local scheduledTapToken = state.tapToken
				task.delay(IY_CRUZAN_WAYPOINT_RETURN.DOUBLE_TAP_SECONDS, function()
					if waypointHoverWindows[state.key] ~= state then return end
					if not state.frame or not state.frame.Parent then return end
					if state.tapToken ~= scheduledTapToken or state.lastTapAt == nil then return end
					state.lastTapAt = nil
					state.lastTapGeneration = nil
					if waypointBackTPEnabled == true then
						IY_CRUZAN_WAYPOINT_RETURN.executeGoto(state)
					end
				end)
			end
		else
			state.lastTapAt = nil
			state.lastTapGeneration = nil
			IY_CRUZAN_WAYPOINT_RETURN.executeGoto(state)
		end
	end

	state.connections[#state.connections + 1] = gotoButton.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if state.dragCandidate then return end
		if activeWaypointHoverDragState and activeWaypointHoverDragState ~= state then
			if activeWaypointHoverDragState.dragCandidate then return end
			activeWaypointHoverDragState = nil
		end
		activeWaypointHoverDragState = state
		bringWaypointHoverToFront(state)
		state.inputToken += 1
		state.dragCandidate = input
		state.dragInput = nil
		state.dragging = false
		state.dragMoved = false
		state.dragStart = input.Position
		state.startPosition = frame.Position
		if state.endConnection then pcall(function() state.endConnection:Disconnect() end) end
		state.endConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				finishWaypointHoverPress(input)
			end
		end)
	end)

	state.connections[#state.connections + 1] = gotoButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			state.dragInput = input
		end
	end)

	state.connections[#state.connections + 1] = closeButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bringWaypointHoverToFront(state)
			frame.Active = true
		end
	end)
	return state
end

local function showWaypointHover(name)
	local waypointName = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if waypointName == "" then return end
	local key = normalizeWaypointHoverKey(waypointName)
	local existing = waypointHoverWindows[key]
	if existing then
		-- Re-hovering an already-open Waypoint fully replaces its old window and resets
		-- only this Waypoint's saved position so it respawns at the default location.
		removeWaypointHoverWindow(existing, false)
		waypointHoverPositions[key] = nil
		if type(updatesaves) == "function" then updatesaves() end
	end

	local state = createWaypointHoverWindow(waypointName, key)
	if not state then return end
	local savedPosition = waypointHoverPositions[key]
	local x, y
	if type(savedPosition) == "table" and tonumber(savedPosition.x) and tonumber(savedPosition.y) then
		x, y = normalizeWaypointHoverPosition(savedPosition.x, savedPosition.y)
	else
		x, y = findDefaultWaypointHoverPosition(state.frame)
	end
	state.frame.Position = UDim2.new(0, x, 0, y)
	waypointHoverWindows[key] = state
	bringWaypointHoverToFront(state)
	state.frame.Visible = true
	local wasSaved = type(savedPosition) == "table" and savedPosition.x == x and savedPosition.y == y
	if not wasSaved then
		waypointHoverPositions[key] = {x = x, y = y}
		if type(updatesaves) == "function" then updatesaves() end
	end
	IY_CRUZAN_WAYPOINT_RETURN.refreshIndicators()
end

local function removeWaypointHoverForName(name)
	local key = normalizeWaypointHoverKey(name)
	if key == "" then return end
	local state = waypointHoverWindows[key]
	if state then removeWaypointHoverWindow(state, false) end
	waypointHoverPositions[key] = nil
end

local function removeAllWaypointHoverWindows()
	local openStates = {}
	for _, state in pairs(waypointHoverWindows) do
		openStates[#openStates + 1] = state
	end
	for _, state in ipairs(openStates) do
		removeWaypointHoverWindow(state, false)
	end
	for key in pairs(waypointHoverPositions) do
		waypointHoverPositions[key] = nil
	end
end

-- Dragging follows the actual mouse/touch movement. With BackTP enabled, a single tap
-- performs Goto after the double-tap interval; a quick second tap requests Return only.
IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputChanged:Connect(function(input)
	-- Only the window that originally received the press may drag. This prevents
	-- a fast touch crossing other open Waypoints from moving those windows too.
	local state = activeWaypointHoverDragState
	if not state then return end
	local candidate = state.dragCandidate
	if not candidate or not state.frame or not state.frame.Parent or input ~= state.dragInput then return end
	local isTouchMove = candidate.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch
	local isMouseMove = candidate.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
	if isTouchMove or isMouseMove then
		local delta = Vector2.new(input.Position.X - state.dragStart.X, input.Position.Y - state.dragStart.Y)
		local movementThreshold = candidate.UserInputType == Enum.UserInputType.Touch
			and IY_CRUZAN_WAYPOINT_RETURN.DRAG_TOUCH_THRESHOLD or IY_CRUZAN_WAYPOINT_RETURN.DRAG_MOUSE_THRESHOLD
		if not state.dragging and delta.Magnitude >= movementThreshold then
			-- Movement always wins over the press duration: moving the window never triggers Goto or Return.
			state.dragging = true
			state.dragMoved = true
			-- A drag cancels any single-tap Goto that is still waiting for the double-tap window.
			state.tapToken = (state.tapToken or 0) + 1
			state.lastTapAt = nil
			state.lastTapGeneration = nil
		end
		if state.dragging then
			local startPosition = state.startPosition
			local x, y = normalizeWaypointHoverPosition(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y)
			state.frame.Position = UDim2.new(0, x, 0, y)
		end
	end
end))

function refreshwaypoints()
	if #WayPoints > 0 or #pWayPoints > 0 then
		PositionsHint:Destroy()
	end
	if Holder_4 then
		Holder_4:ClearAllChildren()
		Holder_4.CanvasSize = UDim2.new(0, 0, 0, 10)
		local YSize = 25
		local num = 1
		for i = 1, #WayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = WayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			table.insert(shade3,newpoint.Text.Hover)
			table.insert(text2,newpoint.Text.Hover)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			local waypointName = tostring(WayPoints[i].NAME)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..waypointName)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..WayPoints[i].NAME)
			end)
			newpoint.Text.Hover.MouseButton1Click:Connect(function()
				showWaypointHover(waypointName)
			end)
			num = num+1
		end
		for i = 1, #pWayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = pWayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			table.insert(shade3,newpoint.Text.Hover)
			table.insert(text2,newpoint.Text.Hover)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			local waypointName = tostring(pWayPoints[i].NAME)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..waypointName)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..pWayPoints[i].NAME)
			end)
			newpoint.Text.Hover.MouseButton1Click:Connect(function()
				showWaypointHover(waypointName)
			end)
			num = num+1
		end
	end
end

refreshwaypoints()

function refreshaliases()
	if #aliases > 0 then
		AliasHint:Destroy()
	end
	if Holder_3 then
		Holder_3:ClearAllChildren()
		Holder_3.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #aliases do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newalias = Example_3:Clone()
			newalias.Parent = Holder_3
			newalias.Visible = true
			newalias.Position = UDim2.new(0,0,0, Position + 5)
			newalias.Text.Text = aliases[i].CMD.." > "..aliases[i].ALIAS
			table.insert(shade2,newalias)
			table.insert(shade2,newalias.Text)
			table.insert(text1,newalias.Text)
			table.insert(shade3,newalias.Text.Delete)
			table.insert(text2,newalias.Text.Delete)
			Holder_3.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newalias.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('removealias '..aliases[i].ALIAS)
			end)
		end
	end
end

local bindChosenKeyUp = false

BindTo.MouseButton1Click:Connect(function()
	awaitingInput = true
	BindTo.Text = 'Press something'
end)

BindTriggerSelect.MouseButton1Click:Connect(function()
	bindChosenKeyUp = not bindChosenKeyUp
	BindTriggerSelect.Text = bindChosenKeyUp and "KeyUp" or "KeyDown"
end)

newToggle = false
Cmdbar_3.Parent.Visible = false
On_2.MouseButton1Click:Connect(function()
	if newToggle == false then newToggle = true
		On_2.BackgroundTransparency = 0
		Cmdbar_3.Parent.Visible = true
		BindTriggerSelect.Visible = false
	else newToggle = false
		On_2.BackgroundTransparency = 1
		Cmdbar_3.Parent.Visible = false
		BindTriggerSelect.Visible = true
	end
end)

Add_2.MouseButton1Click:Connect(function()
	if keySelected then
		if string.find(Cmdbar_2.Text, "\\\\") or string.find(Cmdbar_3.Text, "\\\\") then
			notify('Keybind Error','Only use one backslash to keybind multiple commands into one keybind or command')
		else
			if newToggle and Cmdbar_3.Text ~= '' and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,false,Cmdbar_3.Text)
			elseif not newToggle and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,bindChosenKeyUp)
			else
				return
			end
			refreshbinds()
			updatesaves()
			if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
				notify('Keybinds Updated','Binded '..keyPressed..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			else
				notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			end
		end
	end
end)

Exit_2.MouseButton1Click:Connect(function()
	Cmdbar_2.Text = 'Command'
	Cmdbar_3.Text = 'Command 2'
	BindTo.Text = 'Click to bind'
	bindChosenKeyUp = false
	BindTriggerSelect.Text = "KeyDown"
	keySelected = false
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

function onInputBegan(input,gameProcessed)
	if awaitingInput then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keyPressed = tostring(input.KeyCode)
			BindTo.Text = keyPressed:sub(14)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			keyPressed = 'LeftClick'
			BindTo.Text = 'LeftClick'
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			keyPressed = 'RightClick'
			BindTo.Text = 'RightClick'
		end
		awaitingInput = false
		keySelected = true
	end
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if not v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					if v.TOGGLE then
						local isOn = toggleOn[v] == true
						toggleOn[v] = not isOn
						if isOn then
							execCmd(v.TOGGLE,Players.LocalPlayer)
						else
							execCmd(v.COMMAND,Players.LocalPlayer)
						end
					else
						execCmd(v.COMMAND,Players.LocalPlayer)
					end
				end
			end
		end
	end
end

function onInputEnded(input,gameProcessed)
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					execCmd(v.COMMAND,Players.LocalPlayer)
				end
			end
		end
	end
end

IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputBegan:Connect(onInputBegan))
IY_RELOAD_INSTANCE_STATE.TrackConnection(UserInputService.InputEnded:Connect(onInputEnded))

ClickTP.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clicktp',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click tp')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click tp')
		end
	end
end)

ClickDelete.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clickdel',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click delete')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click delete')
		end
	end
end)

local function clicktpFunc()
	pcall(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
			wait(0.1)
		end

		local hipHeight = humanoid and humanoid.HipHeight > 0 and (humanoid.HipHeight + 1)
		local rootPart = getRoot(character)
		local rootPartPosition = rootPart.Position
		local hitPosition = IYMouse.Hit.Position
		local newCFrame = CFrame.new(
			hitPosition, 
			Vector3.new(rootPartPosition.X, hitPosition.Y, rootPartPosition.Z)
		) * CFrame.Angles(0, math.pi, 0)

		rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
		breakVelocity()
	end)
end

IY_RELOAD_INSTANCE_STATE.TrackConnection(IYMouse.Button1Down:Connect(function()
	for i,v in pairs(binds) do
		if v.COMMAND == 'clicktp' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) and Players.LocalPlayer.Character then
				clicktpFunc()
			end
		elseif v.COMMAND == 'clickdel' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) then
				pcall(function() IYMouse.Target:Destroy() end)
			end
		end
	end
end))

PluginsGUI = PluginEditor.background

function addPlugin(name)
	if name:lower() == 'plugin file name' or name:lower() == 'iy_fe.iy' or name == 'iy_fe' then
		notify('Plugin Error','Please enter a valid plugin')
	else
		local file
		local fileName
		if name:sub(-3) == '.iy' then
			pcall(function() file = readfile(name) end)
			fileName = name
		else
			pcall(function() file = readfile(name..'.iy') end)
			fileName = name..'.iy'
		end
		if file then
			if not FindInTable(PluginsTable, fileName) then
				table.insert(PluginsTable, fileName)
				LoadPlugin(fileName)
				refreshplugins()
				pcall(eventEditor.Refresh)
			else
				notify('Plugin Error','This plugin is already added')
			end
		else
			notify('Plugin Error','Cannot locate file "'..fileName..'". Is the file in the correct folder?')
		end
	end
end

function deletePlugin(name)
	local pName = name..'.iy'
	if name:sub(-3) == '.iy' then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGIN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(CMDsF:GetChildren()) do
		if v.Name == 'PLUGIN_'..pName then
			v:Destroy()
		end
	end
	for i,v in pairs(PluginsTable) do
		if v == pName then
			table.remove(PluginsTable, i)
			notify('Removed Plugin',pName..' was removed')
		end
	end
	IndexContents('',true)
	refreshplugins()
end

function refreshplugins(dontSave)
	if #PluginsTable > 0 then
		PluginsHint:Destroy()
	end
	if Holder_5 then
		Holder_5:ClearAllChildren()
		Holder_5.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i,v in pairs(PluginsTable) do
			local pName = v
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newplugin = Example_5:Clone()
			newplugin.Parent = Holder_5
			newplugin.Visible = true
			newplugin.Position = UDim2.new(0,0,0, Position + 5)
			newplugin.Text.Text = pName
			table.insert(shade2,newplugin)
			table.insert(shade2,newplugin.Text)
			table.insert(text1,newplugin.Text)
			table.insert(shade3,newplugin.Text.Delete)
			table.insert(text2,newplugin.Text.Delete)
			Holder_5.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newplugin.Text.Delete.MouseButton1Click:Connect(function()
				deletePlugin(pName)
			end)
		end
		if not dontSave then
			updatesaves()
		end
	end
end

local PluginCache
function LoadPlugin(val,startup)
	local plugin

	function CatchedPluginLoad()
		plugin = loadfile(val)()
	end

	function handlePluginError(plerror)
		notify('Plugin Error','An error occurred with the plugin, "'..val..'" and it could not be loaded')
		if FindInTable(PluginsTable,val) then
			for i,v in pairs(PluginsTable) do
				if v == val then
					table.remove(PluginsTable,i)
				end
			end
		end
		updatesaves()

		print("Original Error: "..tostring(plerror))
		print("Plugin Error, stack traceback: "..tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			notify('Loaded Plugin',"Name: "..plugin["PluginName"].."\n".."Description: "..plugin["PluginDescription"])
		end
		addcmdtext('',val)
		addcmdtext(string.upper('--'..plugin["PluginName"]),val,plugin["PluginDescription"])
		if plugin["Commands"] then
			for i,v in pairs(plugin["Commands"]) do 
				local cmdExt = ''
				local cmdName = i
				local function handleNames()
					cmdName = i
					if findCmd(cmdName..cmdExt) then
						if isNumber(cmdExt) then
							cmdExt = cmdExt+1
						else
							cmdExt = 1
						end
						handleNames()
					else
						cmdName = cmdName..cmdExt
					end
				end
				handleNames()
				addcmd(cmdName, v["Aliases"], v["Function"], val)
				if v["ListName"] then
					local newName = v.ListName
					local cmdNames = {i,unpack(v.Aliases)}
					for i,v in pairs(cmdNames) do
						newName = newName:gsub(v,v..cmdExt)
					end
					addcmdtext(newName,val,v["Description"])
				else
					addcmdtext(cmdName,val,v["Description"])
				end
			end
		end
		IndexContents('',true)
	elseif plugin == nil then
		plugin = nil
	end
end

function FindPlugins()
	if PluginsTable ~= nil and type(PluginsTable) == "table" then
		for i,v in pairs(PluginsTable) do
			LoadPlugin(v,true)
		end
		refreshplugins(true)
	end
end

AddPlugin.MouseButton1Click:Connect(function()
	addPlugin(PluginsGUI.FileName.Text)
end)

Exit_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	FileName.Text = 'Plugin File Name'
end)

Add_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, 310), "InOut", "Quart", 0.5, true, nil)
end)

Plugins.MouseButton1Click:Connect(function()
	if writefileExploit() then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.5)
		SettingsHolder.Visible = false
	else
		notify('Incompatible Exploit','Your exploit is unable to use plugins (missing read/writefile)')
	end
end)

Close_4.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
end)

IY_RELOAD_INSTANCE_STATE.teleportCheck = false
IY_RELOAD_INSTANCE_STATE.teleportQueueSource = [[
local sourceUrl = "https://raw.githubusercontent.com/cruzann/Infinite-Yield-Cruzan/master/InfiniteYieldCruzan.lua"
local sharedEnv = _G
pcall(function() if type(getgenv) == "function" then sharedEnv = getgenv() end end)
local success, failure = pcall(function()
    local source = game:HttpGet(sourceUrl)
    if type(source) ~= "string" or #source < 100000 then
        error("GitHub returned an empty or incomplete Cruzan script.")
    end
    if not source:find("IY_CRUZAN_RELOAD_V1", 1, true) then
        error("The GitHub file does not contain the current reload-enabled build. Upload the latest InfiniteYieldCruzan.lua first.")
    end
    if type(loadstring) ~= "function" then
        error("This executor does not provide loadstring.")
    end
    local chunk, compileError = loadstring(source)
    if type(chunk) ~= "function" then
        error("Cruzan script failed syntax validation: " .. tostring(compileError))
    end
    local oldState = sharedEnv.IY_CRUZAN_ACTIVE_STATE
    if oldState and type(oldState.SaveSettings) == "function" then
        local saveCallOk, saveResult, saveError = pcall(oldState.SaveSettings)
        if not saveCallOk or saveResult == false then
            warn("Infinite Yield Cruzan: settings save before teleport reload was incomplete: " .. tostring(saveError or saveResult))
        end
    end
    if oldState and type(oldState.Cleanup) == "function" then
        pcall(oldState.Cleanup)
    end
    pcall(function() sharedEnv.IY_LOADED = nil end)
    pcall(function() _G.IY_LOADED = nil end)
    chunk()
end)
if not success then
    warn("Infinite Yield Cruzan auto-reload failed: " .. tostring(failure))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Infinite Yield Cruzan",
            Text = "Auto-reload failed: " .. tostring(failure),
            Duration = 8,
        })
    end)
end
]]
IY_RELOAD_INSTANCE_STATE.TrackConnection(Players.LocalPlayer.OnTeleport:Connect(function(State)
	if KeepInfYield and (not IY_RELOAD_INSTANCE_STATE.teleportCheck) then
		IY_RELOAD_INSTANCE_STATE.teleportCheck = true
		if not queueteleport then
			notify("KeepIY", "This executor does not support queued teleport execution; Cruzan cannot auto-reload after teleport.", 7)
			return
		end
		local queueSuccess, queueError = pcall(queueteleport, IY_RELOAD_INSTANCE_STATE.teleportQueueSource)
		if not queueSuccess then
			notify("KeepIY", "Could not queue Cruzan after teleport: " .. tostring(queueError), 6)
		end
	end
end))

addcmd('addalias',{},function(args, speaker)
	if #args < 2 then return end
	local cmd = string.lower(args[1])
	local alias = string.lower(args[2])
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd or FindInTable(v.ALIAS,cmd) then
			customAlias[alias] = v
			aliases[#aliases + 1] = {CMD = cmd, ALIAS = alias}
			notify('Aliases Modified',"Added "..alias.." as an alias to "..cmd)
			updatesaves()
			refreshaliases()
			break
		end
	end
end)

addcmd('removealias',{},function(args, speaker)
	if #args < 1 then return end
	local alias = string.lower(args[1])
	if customAlias[alias] then
		local cmd = customAlias[alias].NAME
		customAlias[alias] = nil
		for i = #aliases,1,-1 do
			if aliases[i].ALIAS == tostring(alias) then
				table.remove(aliases, i)
			end
		end
		notify('Aliases Modified',"Removed the alias "..alias.." from "..cmd)
		updatesaves()
		refreshaliases()
	end
end)

addcmd('clraliases',{},function(args, speaker)
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard then
		toClipboard('https://discord.com/invite/78ZuWSq')
		notify('Discord Invite', 'Copied to clipboard!\ndiscord.gg/78ZuWSq')
	else
		notify('Discord Invite', 'discord.gg/78ZuWSq')
	end
	if httprequest then
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = '78ZuWSq'}
			})
		})
	end
end)

addcmd('keepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = true
		notify('KeepIY','Infinite Yield will now run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('unkeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = false
		notify('KeepIY','Infinite Yield will no longer run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('togglekeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = not KeepInfYield
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

local canOpenServerinfo = true
addcmd('serverinfo',{'info','sinfo'},function(args, speaker)
	if not canOpenServerinfo then return end
	canOpenServerinfo = false
	task.spawn(function()
		local FRAME = Instance.new("Frame")
		local shadow = Instance.new("Frame")
		local PopupText = Instance.new("TextLabel")
		local Exit = Instance.new("TextButton")
		local ExitImage = Instance.new("ImageLabel")
		local background = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local TextLabel2 = Instance.new("TextLabel")
		local TextLabel3 = Instance.new("TextLabel")
		local Time = Instance.new("TextLabel")
		local appearance = Instance.new("TextLabel")
		local maxplayers = Instance.new("TextLabel")
		local name = Instance.new("TextLabel")
		local placeid = Instance.new("TextLabel")
		local playerid = Instance.new("TextLabel")
		local players = Instance.new("TextLabel")
		local CopyApp = Instance.new("TextButton")
		local CopyPlrID = Instance.new("TextButton")
		local CopyPlcID = Instance.new("TextButton")
		local CopyPlcName = Instance.new("TextButton")

		FRAME.Name = randomString()
		FRAME.Parent = ScaledHolder
		FRAME.Active = true
		FRAME.BackgroundTransparency = 1
		FRAME.Position = UDim2.new(0.5, -130, 0, -500)
		FRAME.Size = UDim2.new(0, 250, 0, 20)
		FRAME.ZIndex = 10
		dragGUI(FRAME)

		shadow.Name = "shadow"
		shadow.Parent = FRAME
		shadow.BackgroundColor3 = currentShade2
		shadow.BorderSizePixel = 0
		shadow.Size = UDim2.new(0, 250, 0, 20)
		shadow.ZIndex = 10
		table.insert(shade2,shadow)

		PopupText.Name = "PopupText"
		PopupText.Parent = shadow
		PopupText.BackgroundTransparency = 1
		PopupText.Size = UDim2.new(1, 0, 0.95, 0)
		PopupText.ZIndex = 10
		PopupText.Font = Enum.Font.SourceSans
		PopupText.TextSize = 14
		PopupText.Text = "Server"
		PopupText.TextColor3 = currentText1
		PopupText.TextWrapped = true
		table.insert(text1,PopupText)

		Exit.Name = "Exit"
		Exit.Parent = shadow
		Exit.BackgroundTransparency = 1
		Exit.Position = UDim2.new(1, -20, 0, 0)
		Exit.Size = UDim2.new(0, 20, 0, 20)
		Exit.Text = ""
		Exit.ZIndex = 10

		ExitImage.Parent = Exit
		ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
		ExitImage.BackgroundTransparency = 1
		ExitImage.Position = UDim2.new(0, 5, 0, 5)
		ExitImage.Size = UDim2.new(0, 10, 0, 10)
		ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
		ExitImage.ZIndex = 10

		background.Name = "background"
		background.Parent = FRAME
		background.Active = true
		background.BackgroundColor3 = currentShade1
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0, 0, 1, 0)
		background.Size = UDim2.new(0, 250, 0, 250)
		background.ZIndex = 10
		table.insert(shade1,background)

		TextLabel.Name = "Text Label"
		TextLabel.Parent = background
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 5, 0, 80)
		TextLabel.Size = UDim2.new(0, 100, 0, 20)
		TextLabel.ZIndex = 10
		TextLabel.Font = Enum.Font.SourceSansLight
		TextLabel.TextSize = 20
		TextLabel.Text = "Run Time:"
		TextLabel.TextColor3 = currentText1
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel)

		TextLabel2.Name = "Text Label2"
		TextLabel2.Parent = background
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 5, 0, 130)
		TextLabel2.Size = UDim2.new(0, 100, 0, 20)
		TextLabel2.ZIndex = 10
		TextLabel2.Font = Enum.Font.SourceSansLight
		TextLabel2.TextSize = 20
		TextLabel2.Text = "Statistics:"
		TextLabel2.TextColor3 = currentText1
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel2)

		TextLabel3.Name = "Text Label3"
		TextLabel3.Parent = background
		TextLabel3.BackgroundTransparency = 1
		TextLabel3.BorderSizePixel = 0
		TextLabel3.Position = UDim2.new(0, 5, 0, 10)
		TextLabel3.Size = UDim2.new(0, 100, 0, 20)
		TextLabel3.ZIndex = 10
		TextLabel3.Font = Enum.Font.SourceSansLight
		TextLabel3.TextSize = 20
		TextLabel3.Text = "Local Player:"
		TextLabel3.TextColor3 = currentText1
		TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel3)

		Time.Name = "Time"
		Time.Parent = background
		Time.BackgroundTransparency = 1
		Time.BorderSizePixel = 0
		Time.Position = UDim2.new(0, 5, 0, 105)
		Time.Size = UDim2.new(0, 100, 0, 20)
		Time.ZIndex = 10
		Time.Font = Enum.Font.SourceSans
		Time.FontSize = Enum.FontSize.Size14
		Time.Text = "LOADING"
		Time.TextColor3 = currentText1
		Time.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,Time)

		appearance.Name = "appearance"
		appearance.Parent = background
		appearance.BackgroundTransparency = 1
		appearance.BorderSizePixel = 0
		appearance.Position = UDim2.new(0, 5, 0, 55)
		appearance.Size = UDim2.new(0, 100, 0, 20)
		appearance.ZIndex = 10
		appearance.Font = Enum.Font.SourceSans
		appearance.FontSize = Enum.FontSize.Size14
		appearance.Text = "Appearance: LOADING"
		appearance.TextColor3 = currentText1
		appearance.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,appearance)

		maxplayers.Name = "maxplayers"
		maxplayers.Parent = background
		maxplayers.BackgroundTransparency = 1
		maxplayers.BorderSizePixel = 0
		maxplayers.Position = UDim2.new(0, 5, 0, 175)
		maxplayers.Size = UDim2.new(0, 100, 0, 20)
		maxplayers.ZIndex = 10
		maxplayers.Font = Enum.Font.SourceSans
		maxplayers.FontSize = Enum.FontSize.Size14
		maxplayers.Text = "LOADING"
		maxplayers.TextColor3 = currentText1
		maxplayers.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,maxplayers)

		name.Name = "name"
		name.Parent = background
		name.BackgroundTransparency = 1
		name.BorderSizePixel = 0
		name.Position = UDim2.new(0, 5, 0, 215)
		name.Size = UDim2.new(0, 240, 0, 30)
		name.ZIndex = 10
		name.Font = Enum.Font.SourceSans
		name.FontSize = Enum.FontSize.Size14
		name.Text = "Place Name: LOADING"
		name.TextColor3 = currentText1
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		table.insert(text1,name)

		placeid.Name = "placeid"
		placeid.Parent = background
		placeid.BackgroundTransparency = 1
		placeid.BorderSizePixel = 0
		placeid.Position = UDim2.new(0, 5, 0, 195)
		placeid.Size = UDim2.new(0, 100, 0, 20)
		placeid.ZIndex = 10
		placeid.Font = Enum.Font.SourceSans
		placeid.FontSize = Enum.FontSize.Size14
		placeid.Text = "Place ID: LOADING"
		placeid.TextColor3 = currentText1
		placeid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,placeid)

		playerid.Name = "playerid"
		playerid.Parent = background
		playerid.BackgroundTransparency = 1
		playerid.BorderSizePixel = 0
		playerid.Position = UDim2.new(0, 5, 0, 35)
		playerid.Size = UDim2.new(0, 100, 0, 20)
		playerid.ZIndex = 10
		playerid.Font = Enum.Font.SourceSans
		playerid.FontSize = Enum.FontSize.Size14
		playerid.Text = "Player ID: LOADING"
		playerid.TextColor3 = currentText1
		playerid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,playerid)

		players.Name = "players"
		players.Parent = background
		players.BackgroundTransparency = 1
		players.BorderSizePixel = 0
		players.Position = UDim2.new(0, 5, 0, 155)
		players.Size = UDim2.new(0, 100, 0, 20)
		players.ZIndex = 10
		players.Font = Enum.Font.SourceSans
		players.FontSize = Enum.FontSize.Size14
		players.Text = "LOADING"
		players.TextColor3 = currentText1
		players.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,players)

		CopyApp.Name = "CopyApp"
		CopyApp.Parent = background
		CopyApp.BackgroundColor3 = currentShade2
		CopyApp.BorderSizePixel = 0
		CopyApp.Position = UDim2.new(0, 210, 0, 55)
		CopyApp.Size = UDim2.new(0, 35, 0, 20)
		CopyApp.Font = Enum.Font.SourceSans
		CopyApp.TextSize = 14
		CopyApp.Text = "Copy"
		CopyApp.TextColor3 = currentText1
		CopyApp.ZIndex = 10
		table.insert(shade2,CopyApp)
		table.insert(text1,CopyApp)

		CopyPlrID.Name = "CopyPlrID"
		CopyPlrID.Parent = background
		CopyPlrID.BackgroundColor3 = currentShade2
		CopyPlrID.BorderSizePixel = 0
		CopyPlrID.Position = UDim2.new(0, 210, 0, 35)
		CopyPlrID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlrID.Font = Enum.Font.SourceSans
		CopyPlrID.TextSize = 14
		CopyPlrID.Text = "Copy"
		CopyPlrID.TextColor3 = currentText1
		CopyPlrID.ZIndex = 10
		table.insert(shade2,CopyPlrID)
		table.insert(text1,CopyPlrID)

		CopyPlcID.Name = "CopyPlcID"
		CopyPlcID.Parent = background
		CopyPlcID.BackgroundColor3 = currentShade2
		CopyPlcID.BorderSizePixel = 0
		CopyPlcID.Position = UDim2.new(0, 210, 0, 195)
		CopyPlcID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcID.Font = Enum.Font.SourceSans
		CopyPlcID.TextSize = 14
		CopyPlcID.Text = "Copy"
		CopyPlcID.TextColor3 = currentText1
		CopyPlcID.ZIndex = 10
		table.insert(shade2,CopyPlcID)
		table.insert(text1,CopyPlcID)

		CopyPlcName.Name = "CopyPlcName"
		CopyPlcName.Parent = background
		CopyPlcName.BackgroundColor3 = currentShade2
		CopyPlcName.BorderSizePixel = 0
		CopyPlcName.Position = UDim2.new(0, 210, 0, 215)
		CopyPlcName.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcName.Font = Enum.Font.SourceSans
		CopyPlcName.TextSize = 14
		CopyPlcName.Text = "Copy"
		CopyPlcName.TextColor3 = currentText1
		CopyPlcName.ZIndex = 10
		table.insert(shade2,CopyPlcName)
		table.insert(text1,CopyPlcName)

		local SINFOGUI = background
		FRAME:TweenPosition(UDim2.new(0.5, -130, 0, 100), "InOut", "Quart", 0.5, true, nil) 
		wait(0.5)
		Exit.MouseButton1Click:Connect(function()
			FRAME:TweenPosition(UDim2.new(0.5, -130, 0, -500), "InOut", "Quart", 0.5, true, nil) 
			wait(0.6)
			FRAME:Destroy()
			canOpenServerinfo = true
		end)
		local Asset = MarketplaceService:GetProductInfo(PlaceId)
		SINFOGUI.name.Text = "Place Name: " .. Asset.Name
		SINFOGUI.playerid.Text = "Player ID: " ..speaker.UserId
		SINFOGUI.maxplayers.Text = Players.MaxPlayers.. " Players Max"
		SINFOGUI.placeid.Text = "Place ID: " ..PlaceId

		CopyApp.MouseButton1Click:Connect(function()
			toClipboard(speaker.CharacterAppearanceId)
		end)
		CopyPlrID.MouseButton1Click:Connect(function()
			toClipboard(speaker.UserId)
		end)
		CopyPlcID.MouseButton1Click:Connect(function()
			toClipboard(PlaceId)
		end)
		CopyPlcName.MouseButton1Click:Connect(function()
			toClipboard(Asset.Name)
		end)

		repeat
			players = Players:GetPlayers()
			SINFOGUI.players.Text = #players.. " Player(s)"
			SINFOGUI.appearance.Text = "Appearance: " ..speaker.CharacterAppearanceId
			local seconds = math.floor(workspace.DistributedGameTime)
			local minutes = math.floor(workspace.DistributedGameTime / 60)
			local hours = math.floor(workspace.DistributedGameTime / 60 / 60)
			local seconds = seconds - (minutes * 60)
			local minutes = minutes - (hours * 60)
			if hours < 1 then if minutes < 1 then
					SINFOGUI.Time.Text = seconds .. " Second(s)" else
					SINFOGUI.Time.Text = minutes .. " Minute(s), " .. seconds .. " Second(s)"
				end
			else
				SINFOGUI.Time.Text = hours .. " Hour(s), " .. minutes .. " Minute(s), " .. seconds .. " Second(s)"
			end
			wait(1)
		until SINFOGUI.Parent == nil
	end)
end)

addcmd("jobid", {}, function(args, speaker)
	toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId',JobId..' / '..PlaceId)
end)

addcmd('breakloops',{'break'},function(args, speaker)
	lastBreakTime = tick()
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	TeleportService:Teleport(args[1])
end)

teleportRespawnHandler = [[
local ok, data = pcall(function() return game:GetService("TeleportService"):GetLocalPlayerTeleportData() end)
if ok and typeof(data) == "CFrame" then
    local Players = game:GetService("Players")
    local ME = Players.LocalPlayer
    while not ME do
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        ME = Players.LocalPlayer
    end

    local Character = ME.Character or ME.CharacterAdded:Wait()
    Character:WaitForChild("HumanoidRootPart")

    local t = tick()
    while (tick() - t) <= 0.3 do
        Character:PivotTo(data)
        task.wait()
    end
end
]]
addcmd("rejoin", {"rj"}, function(args, speaker)
    local data = nil
    if parseBoolean(args[1], false) == true then
        if queueteleport then
            if speaker.Character then
                data = speaker.Character:GetPivot()
                queueteleport(teleportRespawnHandler)
            end
        else
            notify("Incompatible Exploit", "Your exploit does not support this argument (missing queue_on_teleport)")
        end
    end

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer, nil, data)
    end
end)

addcmd("inviteprompt", {}, function(args, speaker)
	local plrs = getPlayer(args[1], speaker)
	if #plrs > 0 then
		ExperienceService:LaunchExperience({
			placeId = PlaceId,
			gameInstanceId = JobId,
			referredByPlayerId = plr[1].UserId
		})
	end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	if autoRejoinConnection then pcall(function() autoRejoinConnection:Disconnect() end) end
	autoRejoinConnection = GuiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
	-- thanks to Amity for fixing
	local servers = {}
	local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
	local body = HttpService:JSONDecode(req)

	if body and body.data then
		for i, v in next, body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
				table.insert(servers, 1, v.id)
			end
		end
	end

	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
	else
		return notify("Serverhop", "Couldn't find a server.")
	end
end)

addcmd("exit", {"shutdown", "leave"}, function(args, speaker)
	game:Shutdown()
end)

local NoclipParts = {}
local Noclipping = nil
addcmd("noclip", {}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = false
    task.wait(0.1)
    NoclipParts = {}
    Noclipping = RunService.Stepped:Connect(function()
        if Clip == false and speaker.Character ~= nil then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                    NoclipParts[child] = true
                end
            end
        end
    end)
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Enabled")
end)

addcmd("unnoclip", {"clip"}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = true
    task.wait(0.1)
    for child, _ in pairs(NoclipParts) do
        if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
            child.CanCollide = true
        end
    end
    NoclipParts = {}
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Disabled")
end)

addcmd("togglenoclip", {}, function(args, speaker)
    execCmd(Clip and "noclip" or "unnoclip")
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

-- Recorder integration: suspend the built-in fly controller before replay so its live input
-- does not fight the recorded velocity/orientation stream. This is assigned after both
-- desktop and mobile cleanup functions exist; Record calls it only after full script startup.
IY_RELOAD_INSTANCE_STATE.stopFlyForRecordPlayback = function()
	local active = false
	pcall(function() active = FLYING == true end)
	if not active then return true end
	local ok = pcall(function()
		if IsOnMobile then
			unmobilefly(Players.LocalPlayer)
		else
			NOFLY()
		end
	end)
	if not ok then return false end
	pcall(function() task.wait(0.12) end)
	return FLYING ~= true
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

addcmd('fly',{},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY(true) else mobilefly(speaker, true) end
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY() else mobilefly(speaker) end
	end
end)

CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	-- Full credit to peyton#9148 (apeyton)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

floating = false
local beganListener: RBXScriptConnection
local endListener: RBXScriptConnection
local floatingFunc: RBXScriptConnection

addcmd('float', {'platform'},function(args, speaker)
	local pchar = speaker.Character
	floatName = randomString()
	floating = true
	
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local floatPoint = -3.1
			local floatPart = Instance.new('Part')
			floatPart.Name = floatName
			floatPart.Parent = pchar
			floatPart.Transparency = 1
			floatPart.Size = Vector3.new(2, 0.2, 1.5)
			floatPart.Anchored = true
			
			notify('Float', 'Started floating (Q = down & E = up)')
			
			beganListener = UserInputService.InputBegan:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint -= 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint += 1.5
				end
			end)
			endListener = UserInputService.InputEnded:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint += 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint -= 1.5
				end
			end)
			
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				floatingFunc:Disconnect()
				floatPart:Destroy()
				floatDied:Disconnect()
				beganListener:Disconnect()
				endListener:Disconnect()
				floatName = nil
			end)
			local function floatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					floatPart.CFrame = getRoot(pchar).CFrame * CFrame.new(0, floatPoint, 0)
				else
					floatingFunc:Disconnect()
					floatPart:Destroy()
					floatDied:Disconnect()
					beganListener:Disconnect()
					endListener:Disconnect()
					floatName = nil
				end
			end			
			floatingFunc = RunService.PreAnimation:Connect(floatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	floating = false
	local pchar = speaker.Character
	notify('Float', 'Stopped floating')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		floatingFunc:Disconnect()
		floatDied:Disconnect()
		beganListener:Disconnect()
		endListener:Disconnect()
		floatName = nil
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				getRoot(speaker.Character).Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and getRoot(speaker.Character).Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if gravReset then
			gravReset:Disconnect()
		end
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd('setwaypoint',{'swp','setwp','spos','saveposition','savepos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		local torso = getRoot(speaker.Character)
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypointpos',{'wpp','setwaypointposition','setpos','setwaypoint','setwaypointpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypoints',{'positions'},function(args, speaker)
	waypointPanelTransitionToken += 1
	waypointPanelState = "waypoints"
	WaypointClearConfirmFrame.Visible = false
	WaypointClearConfirmFrame.Position = waypointPanelHiddenPosition
	WaypointAddDialog.Visible = false
	WaypointAddDialog.Position = waypointPanelHiddenPosition
	PositionsFrame.Visible = true
	if SettingsOpen == false then setSettingsOpenState(true)
		setSettingsBackdrop(true)
		Settings:TweenPosition(UDim2.new(0, 0, 0, 20), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	end
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
	AliasAddDialog.Visible = false
	AliasAddDialog.Position = UDim2.new(0, 0, 0, 200)
	AliasClearConfirmFrame.Visible = false
	AliasClearConfirmFrame.Position = UDim2.new(0, 0, 0, 200)
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 200), "InOut", "Quart", 0.5, true, nil)
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
	maximizeHolder()
end)

waypointParts = {}
addcmd('showwaypoints',{'showwp','showwps'},function(args, speaker)
	execCmd('hidewaypoints')
	wait()
	for i,_ in pairs(WayPoints) do
		local x = WayPoints[i].COORD[1]
		local y = WayPoints[i].COORD[2]
		local z = WayPoints[i].COORD[3]
		local part = Instance.new("Part")
		part.Size = Vector3.new(5,5,5)
		part.CFrame = CFrame.new(x,y,z)
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		table.insert(waypointParts,part)
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = part
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = part.Size
		view.Parent = part
	end
	for i,v in pairs(pWayPoints) do
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = pWayPoints[i].COORD[1]
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = pWayPoints[i].COORD[1].Size
		view.Parent = pWayPoints[i].COORD[1]
		table.insert(waypointParts,view)
	end
end)

addcmd('hidewaypoints',{'hidewp','hidewps'},function(args, speaker)
	for i,v in pairs(waypointParts) do
		v:Destroy()
	end
	waypointParts = {}
end)

addcmd('waypoint',{'wp','lpos','loadposition','loadpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				local x = WayPoints[i].COORD[1]
				local y = WayPoints[i].COORD[2]
				local z = WayPoints[i].COORD[3]
				getRoot(speaker.Character).CFrame = CFrame.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				getRoot(speaker.Character).CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweenwaypoint',{'twp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)}):Play()
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)}):Play()
			end
		end
	end
end)

addcmd('walktowaypoint',{'wtwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

addcmd('deletewaypoint',{'dwp','dpos','deleteposition','deletepos'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			removeWaypointHoverForName(v.NAME)
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.NAME:lower() == tostring(getstring(1, args)):lower() then
				if not v.GAME or v.GAME == PlaceId then
					table.remove(AllWaypoints, i)
				end
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			removeWaypointHoverForName(v.NAME)
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
end)

addcmd('clearwaypoints',{'cwp','clearpositions','cpos','clearpos'},function(args, speaker)
	removeAllWaypointHoverWindows()
	WayPoints = {}
	pWayPoints = {}
	refreshwaypoints()
	updatesaves()
	AllWaypoints = {}
	notify('Modified Waypoints','Removed all waypoints')
end)

addcmd('cleargamewaypoints',{'cgamewp'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.GAME == PlaceId then
			removeWaypointHoverForName(v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.GAME == PlaceId then
				table.remove(AllWaypoints, i)
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.GAME == PlaceId then
			removeWaypointHoverForName(v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
	notify('Modified Waypoints','Deleted game waypoints')
end)


local coreGuiTypeNames = {
	-- predefined aliases
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu
}

-- Load the full list of enums
for _, enumItem in ipairs(Enum.CoreGuiType:GetEnumItems()) do
	coreGuiTypeNames[enumItem.Name:lower()] = enumItem
end

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)


local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
				deleteGuisAtPos()
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

wasStayOpen = StayOpen
addcmd('hideiy',{},function(args, speaker)
	isHidden = true
	wasStayOpen = StayOpen
	if StayOpen == true then
		StayOpen = false
		updateStayOpenVisual()
	end
	minimizeNum = 0
	minimizeHolder()
	if not (args[1] and tostring(args[1]) == 'nonotify') then notify('IY Hidden','You can press the prefix key to access the command bar') end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
	isHidden = false
	minimizeNum = -20
	if wasStayOpen then
		maximizeHolder()
		StayOpen = true
		updateStayOpenVisual()
	else
		minimizeHolder()
	end
end)

addcmd('rec', {}, function(args, speaker)
	return COREGUI:ToggleRecording()
end)

-- IY_CRUZAN_MOVEMENT_RECORD_V4
-- Records movement inputs and jump events at a 60 Hz target; flight playback preserves recorded orientation.
-- Flight replication remains best-effort when the source uses a third-party controller.
-- Playback restores the recorded starting CFrame once, then replays movement via Humanoid input/physics.
-- Keep optional recorder initialization fail-soft so an executor/filesystem mismatch cannot abort the main UI.
local __iyRecordConnStart = #(IY_RELOAD_INSTANCE_STATE.connections or {})
local __iyRecordInstanceStart = #(IY_RELOAD_INSTANCE_STATE.ownedInstances or {})
local __iyRecordInitOk, __iyRecordInitError = pcall(function()
do
	local sharedEnv = IY_RELOAD_INSTANCE_STATE.sharedEnv or _G
	local recordData = type(sharedEnv.IY_CRUZAN_MOVEMENT_RECORD_DATA) == "table" and sharedEnv.IY_CRUZAN_MOVEMENT_RECORD_DATA or {saved = nil}
	local MovementRecord = {
		mode = "idle",
		saved = recordData.saved,
		currentSamples = nil,
		connection = nil,
		startedAt = nil,
		lastSampleAt = nil,
		recordingCharacter = nil,
		recordingRoot = nil,
		recordingHumanoid = nil,
		recordingEventConnections = {},
		pendingJumpPulse = false,
		recordingPlaceId = nil,
		recordingGameId = nil,
		recordingStartCFrame = nil,
		recordingSessionId = nil,
		recordingBasePath = nil,
		recordingManifestPath = nil,
		recordingPendingPath = nil,
		recordingPersistent = false,
		recordingPersistedSampleCount = 0,
		recordingChunkCount = 0,
		recordingChunkBytes = 0,
		playbackLoopIndex = 0,
		approach = nil,
		approachGyro = nil,
		playbackCharacter = nil,
		playbackHumanoid = nil,
		playbackRoot = nil,
		playbackStartedAt = nil,
		playbackLoop = false,
		playbackLastElapsed = 0,
		playbackLastSampleIndex = 0,
		playbackJumpResetPending = false,
		playbackJumpPendingUntil = nil,
		playbackJumpLastAttemptAt = 0,
		playbackJumpLastAttemptElapsed = nil,
		recordingFlightLatched = false,
		recordingFlightLastExplicitAt = nil,
		recordingFlightReleaseCount = 0,
		recordingFastFlightCount = 0,
		controls = nil,
		flightMover = nil,
		flightGyro = nil,
		trajectoryMover = nil,
		originalProperties = nil,
		sampleInterval = 1 / 60,
		maxMemorySamples = 36000,
		maxPersistentBytes = 10 * 1024 * 1024,
		persistChunkSamples = 300,
		ui = nil,
	}

	local function recordNotify(message, duration)
		pcall(function() notify("Record", message, duration or 3) end)
	end

	local RECORD_FOLDER = "IY_Cruzan_Recordings"
	local RECORD_CHUNK_SIZE = MovementRecord.persistChunkSamples -- five-second chunks at the 60 Hz target
	local RECORD_MAX_BYTES = MovementRecord.maxPersistentBytes
	local RECORD_MAX_MEMORY_SAMPLES = MovementRecord.maxMemorySamples
	local CURRENT_GAME_ID = tostring(game.GameId or 0)
	local CURRENT_PLACE_ID = tonumber(game.PlaceId) or 0
	local RECORD_PLACE_KEY = CURRENT_GAME_ID .. ":" .. tostring(CURRENT_PLACE_ID)

	if type(recordData.byPlace) ~= "table" then recordData.byPlace = {} end

	local function pathToken(value)
		local token = tostring(value or "0"):gsub("[^%w%-_]", "_")
		if token == "" then token = "0" end
		return token
	end

	local function recordPaths(gameId, placeId)
		local base = RECORD_FOLDER .. "/g" .. pathToken(gameId) .. "_p" .. pathToken(placeId)
		return {base = base, manifest = base .. ".json", pending = base .. ".pending.json"}
	end

	local function safeFileRead(path)
		if type(readfile) ~= "function" then return nil end
		local ok, value = pcall(function()
			local first, second = readfile(path, true)
			if first == true then return second end
			if type(first) == "string" then return first end
			return nil
		end)
		return ok and type(value) == "string" and value or nil
	end

	local function safeFileWrite(path, data)
		if type(writefile) ~= "function" then return false, "writefile is unavailable" end
		local ok, result, detail = pcall(function() return writefile(path, data, true) end)
		if not ok then return false, tostring(result) end
		if result == false then return false, tostring(detail or "writefile failed") end
		return true
	end

	local function safeFileDelete(path)
		if type(delfile) ~= "function" then return false end
		local ok = pcall(delfile, path)
		return ok
	end

	local function ensureRecordFolder()
		if type(writefile) ~= "function" or type(readfile) ~= "function" or not HttpService then
			return false
		end
		if type(isfolder) == "function" then
			local ok, exists = pcall(isfolder, RECORD_FOLDER)
			if ok and exists then return true end
		end
		if type(makefolder) == "function" then pcall(makefolder, RECORD_FOLDER) end
		local probe = RECORD_FOLDER .. "/.iy_record_probe"
		local ok = safeFileWrite(probe, "ok")
		if ok then
			safeFileDelete(probe)
			return true
		end
		if type(isfolder) == "function" then
			local checkOk, exists = pcall(isfolder, RECORD_FOLDER)
			return checkOk and exists == true
		end
		return false
	end

	local function safeJsonEncode(value)
		local ok, result = pcall(function() return HttpService:JSONEncode(value) end)
		return ok and type(result) == "string" and result or nil
	end

	local function safeJsonRead(path)
		local raw = safeFileRead(path)
		if not raw then return nil end
		local ok, value = pcall(function() return HttpService:JSONDecode(raw) end)
		return ok and type(value) == "table" and value or nil
	end

	local function rounded(value, digits)
		value = tonumber(value) or 0
		if value ~= value or math.abs(value) > 10000000 then value = 0 end
		local scale = 10 ^ (digits or 3)
		if value >= 0 then return math.floor(value * scale + 0.5) / scale end
		return math.ceil(value * scale - 0.5) / scale
	end

	local function packCFrame(value)
		if not value then return nil end
		local ok, packed = pcall(function()
			local pos = value.Position
			local rx, ry, rz = value:ToOrientation()
			return {rounded(pos.X, 4), rounded(pos.Y, 4), rounded(pos.Z, 4), rounded(rx, 5), rounded(ry, 5), rounded(rz, 5)}
		end)
		return ok and packed or nil
	end

	local function unpackCFrame(value)
		if type(value) ~= "table" or #value < 6 then return nil end
		local ok, result = pcall(function()
			return CFrame.new(tonumber(value[1]) or 0, tonumber(value[2]) or 0, tonumber(value[3]) or 0)
				* CFrame.fromOrientation(tonumber(value[4]) or 0, tonumber(value[5]) or 0, tonumber(value[6]) or 0)
		end)
		return ok and result or nil
	end

	-- Compact numeric arrays avoid serializing Roblox Vector3/CFrame userdata directly.
	local function packMovementSample(sample)
		local cf = packCFrame(sample.cframe)
		if not cf then return nil end
		local move = sample.move or Vector3.zero
		local velocity = sample.pathVelocity or Vector3.zero
		local flightCFrame = packCFrame(sample.flightCFrame or sample.cframe) or cf
		local flightVelocity = sample.flightVelocity or Vector3.zero
		local flightMaxForce = sample.flightMaxForce or Vector3.new(9000000000, 9000000000, 9000000000)
		local flightMaxTorque = sample.flightMaxTorque or Vector3.new(9000000000, 9000000000, 9000000000)
		return {
			math.floor((tonumber(sample.t) or 0) * 1000 + 0.5),
			cf[1], cf[2], cf[3], cf[4], cf[5], cf[6],
			rounded(move.X, 3), rounded(move.Y, 3), rounded(move.Z, 3),
			sample.jump and 1 or 0,
			rounded(sample.walkSpeed or 16, 2), rounded(sample.jumpPower or 50, 2),
			rounded(sample.jumpHeight or 7.2, 2), sample.useJumpPower == false and 0 or 1,
			sample.flight and 1 or 0,
			rounded(velocity.X, 2), rounded(velocity.Y, 2), rounded(velocity.Z, 2),
			tostring(sample.state or "Unknown"),
			sample.flightControl and 1 or 0,
			flightCFrame[1], flightCFrame[2], flightCFrame[3], flightCFrame[4], flightCFrame[5], flightCFrame[6],
			rounded(flightVelocity.X, 2), rounded(flightVelocity.Y, 2), rounded(flightVelocity.Z, 2),
			rounded(sample.flightVelocityP or 1250, 2), rounded(sample.flightGyroP or 1000, 2), rounded(sample.flightGyroD or 50, 2),
			rounded(flightMaxForce.X, 2), rounded(flightMaxForce.Y, 2), rounded(flightMaxForce.Z, 2),
			rounded(flightMaxTorque.X, 2), rounded(flightMaxTorque.Y, 2), rounded(flightMaxTorque.Z, 2)
		}
	end

	local function unpackMovementSample(row)
		if type(row) ~= "table" or #row < 19 then return nil end
		local cf = unpackCFrame({row[2], row[3], row[4], row[5], row[6], row[7]})
		if not cf then return nil end
		local function n(index, fallback) return tonumber(row[index]) or fallback or 0 end
		local hasFlightControl = n(21, 0) == 1 and #row >= 30
		local flightCFrame = hasFlightControl and unpackCFrame({row[22], row[23], row[24], row[25], row[26], row[27]}) or nil
		local flightVelocity = hasFlightControl and Vector3.new(n(28), n(29), n(30)) or nil
		local flightMaxForce = hasFlightControl and #row >= 39 and Vector3.new(n(34), n(35), n(36)) or nil
		local flightMaxTorque = hasFlightControl and #row >= 39 and Vector3.new(n(37), n(38), n(39)) or nil
		return {
			t = n(1, 0) / 1000,
			cframe = cf,
			move = Vector3.new(n(8), n(9), n(10)),
			jump = n(11) == 1,
			walkSpeed = n(12, 16),
			jumpPower = n(13, 50),
			jumpHeight = n(14, 7.2),
			useJumpPower = n(15, 1) == 1,
			flight = n(16) == 1,
			pathVelocity = Vector3.new(n(17), n(18), n(19)),
			state = tostring(row[20] or "Unknown"),
			flightControl = hasFlightControl,
			flightCFrame = flightCFrame,
			flightVelocity = flightVelocity,
			flightVelocityP = hasFlightControl and n(31, 1250) or nil,
			flightGyroP = hasFlightControl and n(32, 1000) or nil,
			flightGyroD = hasFlightControl and n(33, 50) or nil,
			flightMaxForce = flightMaxForce,
			flightMaxTorque = flightMaxTorque,
		}
	end

	local function recordChunkPath(base, sessionId, chunkIndex)
		return base .. "_" .. pathToken(sessionId) .. "_c" .. string.format("%04d", chunkIndex) .. ".json"
	end

	local function readManifest(path)
		return safeJsonRead(path)
	end

	local function deleteManifestChunks(manifest, base)
		if type(manifest) ~= "table" or type(manifest.sessionId) ~= "string" then return end
		local count = math.min(2000, math.max(0, tonumber(manifest.chunks) or 0))
		for index = 1, count do safeFileDelete(recordChunkPath(base, manifest.sessionId, index)) end
	end

	local function hydrateManifest(manifest, paths)
		if type(manifest) ~= "table" or manifest.deleted == true then return nil end
		if tostring(manifest.gameId or "") ~= CURRENT_GAME_ID or tonumber(manifest.placeId) ~= CURRENT_PLACE_ID then return nil end
		local chunkCount = tonumber(manifest.chunks) or 0
		local declaredSamples = tonumber(manifest.sampleCount) or 0
		if chunkCount < 1 or chunkCount > 2000 or declaredSamples < 2 or declaredSamples > RECORD_MAX_MEMORY_SAMPLES then return nil end
		local sessionId = tostring(manifest.sessionId or "")
		if sessionId == "" then return nil end
		local samples = {}
		for index = 1, chunkCount do
			local chunk = safeJsonRead(recordChunkPath(paths.base, sessionId, index))
			if not chunk or type(chunk.data) ~= "table" then break end
			for _, row in ipairs(chunk.data) do
				local sample = unpackMovementSample(row)
				if sample then
					samples[#samples + 1] = sample
					if #samples >= RECORD_MAX_MEMORY_SAMPLES then break end
				end
			end
			if #samples >= RECORD_MAX_MEMORY_SAMPLES then break end
		end
		if #samples < 2 then return nil end
		local startCFrame = unpackCFrame(manifest.start) or samples[1].cframe
		return {
			samples = samples,
			duration = tonumber(samples[#samples].t) or tonumber(manifest.duration) or 0,
			startCFrame = startCFrame,
			gameId = CURRENT_GAME_ID,
			placeId = CURRENT_PLACE_ID,
			version = tonumber(manifest.version) or 3,
			sampleRate = tonumber(manifest.sampleRate) or 60,
			sessionId = sessionId,
			persistentBasePath = paths.base,
			recoveredPartial = manifest.complete ~= true,
		}
	end

	local function loadPersistedRecording()
		local paths = recordPaths(CURRENT_GAME_ID, CURRENT_PLACE_ID)
		local finalManifest = readManifest(paths.manifest)
		local pendingManifest = readManifest(paths.pending)
		local finalSaved = hydrateManifest(finalManifest, paths)
		local pendingSaved = hydrateManifest(pendingManifest, paths)
		local finalTime = tonumber(finalManifest and finalManifest.updatedAt) or 0
		local pendingTime = tonumber(pendingManifest and pendingManifest.updatedAt) or 0
		local tombstoneTime = -1
		if finalManifest and finalManifest.deleted == true then tombstoneTime = math.max(tombstoneTime, finalTime) end
		if pendingManifest and pendingManifest.deleted == true then tombstoneTime = math.max(tombstoneTime, pendingTime) end
		-- A clear tombstone must suppress older checkpoint files, unless a newer recording has begun afterwards.
		if pendingSaved and pendingTime > tombstoneTime and (not finalSaved or pendingTime > finalTime
			or (pendingSaved.sessionId ~= finalSaved.sessionId and pendingTime == finalTime and #pendingSaved.samples > #finalSaved.samples)) then
			return pendingSaved, true
		end
		if finalSaved and finalTime > tombstoneTime then return finalSaved, false end
		return nil, false
	end

	local function syncSavedRecording()
		recordData.byPlace = type(recordData.byPlace) == "table" and recordData.byPlace or {}
		recordData.byPlace[RECORD_PLACE_KEY] = MovementRecord.saved
		recordData.saved = MovementRecord.saved -- legacy compatibility for older script reloads
		recordData.gameId = CURRENT_GAME_ID
		recordData.placeId = CURRENT_PLACE_ID
		sharedEnv.IY_CRUZAN_MOVEMENT_RECORD_DATA = recordData
	end

	local function refreshSavedRecording()
		local liveData = sharedEnv.IY_CRUZAN_MOVEMENT_RECORD_DATA
		if type(liveData) == "table" then
			recordData = liveData
			recordData.byPlace = type(recordData.byPlace) == "table" and recordData.byPlace or {}
			local placeSaved = recordData.byPlace[RECORD_PLACE_KEY]
			local legacySaved = recordData.saved
			local legacyMatchesPlace = type(legacySaved) == "table"
				and tonumber(legacySaved.placeId) == CURRENT_PLACE_ID
				and (legacySaved.gameId == nil or tostring(legacySaved.gameId) == CURRENT_GAME_ID)
			-- Honour explicit writes through the legacy field too; older versions and integrations only set .saved.
			if legacyMatchesPlace and legacySaved ~= placeSaved then
				MovementRecord.saved = legacySaved
			elseif placeSaved then
				MovementRecord.saved = placeSaved
			else
				MovementRecord.saved = legacyMatchesPlace and legacySaved or nil
			end
		end
	end

	local function activeManifest(sampleCount, chunkCount, complete)
		local samples = MovementRecord.currentSamples or {}
		local last = samples[sampleCount]
		return {
			version = 4,
			gameId = MovementRecord.recordingGameId or CURRENT_GAME_ID,
			placeId = MovementRecord.recordingPlaceId or CURRENT_PLACE_ID,
			sessionId = MovementRecord.recordingSessionId,
			chunks = chunkCount,
			sampleCount = sampleCount,
			duration = last and tonumber(last.t) or 0,
			start = packCFrame(MovementRecord.recordingStartCFrame),
			sampleRate = 60,
			complete = complete == true,
			updatedAt = os.time(),
		}
	end

	local function flushRecordingChunks(finalFlush)
		if not MovementRecord.recordingPersistent then return true end
		local samples = MovementRecord.currentSamples or {}
		while true do
			local available = #samples - (MovementRecord.recordingPersistedSampleCount or 0)
			if available <= 0 then return true end
			if not finalFlush and available < RECORD_CHUNK_SIZE then return true end
			local count = math.min(RECORD_CHUNK_SIZE, available)
			local firstIndex = (MovementRecord.recordingPersistedSampleCount or 0) + 1
			local packed = {}
			for index = firstIndex, firstIndex + count - 1 do
				local row = packMovementSample(samples[index])
				if not row then return false, "serializeError" end
				packed[#packed + 1] = row
			end
			local chunkRaw = safeJsonEncode({version = 1, data = packed})
			if not chunkRaw then return false, "serializeError" end
			local nextChunkCount = (MovementRecord.recordingChunkCount or 0) + 1
			local nextSampleCount = (MovementRecord.recordingPersistedSampleCount or 0) + count
			local manifestRaw = safeJsonEncode(activeManifest(nextSampleCount, nextChunkCount, false))
			if not manifestRaw then return false, "serializeError" end
			if (MovementRecord.recordingChunkBytes or 0) + #chunkRaw + #manifestRaw > RECORD_MAX_BYTES then
				return false, "maxBytes"
			end
			local chunkPath = recordChunkPath(MovementRecord.recordingBasePath, MovementRecord.recordingSessionId, nextChunkCount)
			local wroteChunk, chunkError = safeFileWrite(chunkPath, chunkRaw)
			if not wroteChunk then return false, "writeError: " .. tostring(chunkError) end
			local wroteManifest, manifestError = safeFileWrite(MovementRecord.recordingPendingPath, manifestRaw)
			if not wroteManifest then
				safeFileDelete(chunkPath)
				return false, "writeError: " .. tostring(manifestError)
			end
			MovementRecord.recordingChunkCount = nextChunkCount
			MovementRecord.recordingPersistedSampleCount = nextSampleCount
			MovementRecord.recordingChunkBytes = (MovementRecord.recordingChunkBytes or 0) + #chunkRaw
			if not finalFlush and #samples - MovementRecord.recordingPersistedSampleCount < RECORD_CHUNK_SIZE then return true end
		end
	end

	local function finalizePersistentRecording(saved)
		if not MovementRecord.recordingPersistent then return false, "persistent storage is unavailable" end
		local paths = recordPaths(saved.gameId or CURRENT_GAME_ID, saved.placeId or CURRENT_PLACE_ID)
		local oldManifest = readManifest(paths.manifest)
		local finalManifest = {
			version = 4,
			gameId = tostring(saved.gameId or CURRENT_GAME_ID),
			placeId = tonumber(saved.placeId) or CURRENT_PLACE_ID,
			sessionId = MovementRecord.recordingSessionId,
			chunks = MovementRecord.recordingChunkCount or 0,
			sampleCount = #saved.samples,
			duration = tonumber(saved.duration) or 0,
			start = packCFrame(saved.startCFrame or saved.samples[1].cframe),
			sampleRate = 60,
			complete = true,
			updatedAt = os.time(),
		}
		local raw = safeJsonEncode(finalManifest)
		if not raw then return false, "could not encode the final manifest" end
		if (MovementRecord.recordingChunkBytes or 0) + #raw > RECORD_MAX_BYTES then return false, "recording file limit reached" end
		local ok, err = safeFileWrite(paths.manifest, raw)
		if not ok then return false, tostring(err) end
		safeFileDelete(paths.pending)
		if oldManifest and oldManifest.sessionId and oldManifest.sessionId ~= finalManifest.sessionId then
			deleteManifestChunks(oldManifest, paths.base)
		end
		saved.sessionId = finalManifest.sessionId
		saved.persistentBasePath = paths.base
		saved.recoveredPartial = false
		return true
	end

	local function getLocalCharacterParts()
		local player = Players.LocalPlayer
		local character = player and player.Character
		if not character then return nil, nil, nil end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = getRoot(character)
		if not humanoid or not root or humanoid.Health <= 0 then return character, humanoid, nil end
		return character, humanoid, root
	end

	local function getHumanoidStateName(humanoid)
		local ok, result = pcall(function() return humanoid:GetState().Name end)
		return ok and tostring(result) or "Unknown"
	end

	local function disconnectRecordConnection()
		local connection = MovementRecord.connection
		MovementRecord.connection = nil
		if connection then
			pcall(function() connection:Disconnect() end)
			local state = IY_RELOAD_INSTANCE_STATE
			if state and type(state.connections) == "table" then
				for index = #state.connections, 1, -1 do
					if state.connections[index] == connection then table.remove(state.connections, index) end
				end
			end
		end
	end

	local function resetRootVelocity(root)
		if not root then return end
		pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
		pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
	end

	local function clampVectorMagnitude(vector, maxMagnitude)
		if not vector then return Vector3.zero end
		local magnitude = vector.Magnitude
		if magnitude > maxMagnitude and magnitude > 0 then
			return vector.Unit * maxMagnitude
		end
		return vector
	end

	local function removeTrajectoryMover()
		local mover = MovementRecord.trajectoryMover
		MovementRecord.trajectoryMover = nil
		if mover then pcall(function() mover:Destroy() end) end
	end

	local function ensureTrajectoryMover(root)
		local mover = MovementRecord.trajectoryMover
		if not mover or mover.Parent ~= root then
			removeTrajectoryMover()
			local ok, created = pcall(function()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "IY_CruzanRecordTrajectoryVelocity"
				bodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
				bodyVelocity.P = 18000
				bodyVelocity.Velocity = Vector3.zero
				bodyVelocity.Parent = root
				return bodyVelocity
			end)
			if not ok then return nil end
			MovementRecord.trajectoryMover = created
			mover = created
		end
		return mover
	end

	local function removeFlightMover()
		local mover = MovementRecord.flightMover
		local gyro = MovementRecord.flightGyro
		MovementRecord.flightMover = nil
		MovementRecord.flightGyro = nil
		if mover then pcall(function() mover:Destroy() end) end
		if gyro then pcall(function() gyro:Destroy() end) end
	end

	local function ensureFlightMover(root)
		local mover = MovementRecord.flightMover
		if not mover or mover.Parent ~= root then
			removeFlightMover()
			local ok, created = pcall(function()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "IY_CruzanRecordFlightVelocity"
				bodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
				bodyVelocity.P = 1250
				bodyVelocity.Velocity = Vector3.zero
				bodyVelocity.Parent = root
				return bodyVelocity
			end)
			if not ok then return nil end
			MovementRecord.flightMover = created
			mover = created
		end
		local gyro = MovementRecord.flightGyro
		if not gyro or gyro.Parent ~= root then
			if gyro then pcall(function() gyro:Destroy() end) end
			local gyroOk, createdGyro = pcall(function()
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.Name = "IY_CruzanRecordFlightOrientation"
				bodyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
				bodyGyro.P = 1000
				bodyGyro.D = 50
				bodyGyro.CFrame = root.CFrame
				bodyGyro.Parent = root
				return bodyGyro
			end)
			if gyroOk then MovementRecord.flightGyro = createdGyro end
		end
		return mover
	end

	local function disconnectRecordingEventConnections()
		local connections = MovementRecord.recordingEventConnections or {}
		MovementRecord.recordingEventConnections = {}
		for _, connection in ipairs(connections) do
			pcall(function() connection:Disconnect() end)
			local state = IY_RELOAD_INSTANCE_STATE
			if state and type(state.connections) == "table" then
				for index = #state.connections, 1, -1 do
					if state.connections[index] == connection then table.remove(state.connections, index) end
				end
			end
		end
	end

	local function trackRecordingEventConnection(connection)
		if not connection then return end
		MovementRecord.recordingEventConnections = MovementRecord.recordingEventConnections or {}
		table.insert(MovementRecord.recordingEventConnections, connection)
		if IY_RELOAD_INSTANCE_STATE and type(IY_RELOAD_INSTANCE_STATE.TrackConnection) == "function" then
			IY_RELOAD_INSTANCE_STATE.TrackConnection(connection)
		end
	end

	local function clearRecordingReferences()
		disconnectRecordingEventConnections()
		MovementRecord.currentSamples = nil
		MovementRecord.startedAt = nil
		MovementRecord.lastSampleAt = nil
		MovementRecord.recordingCharacter = nil
		MovementRecord.recordingRoot = nil
		MovementRecord.recordingHumanoid = nil
		MovementRecord.pendingJumpPulse = false
		MovementRecord.recordingPlaceId = nil
		MovementRecord.recordingGameId = nil
		MovementRecord.recordingStartCFrame = nil
		MovementRecord.recordingSessionId = nil
		MovementRecord.recordingBasePath = nil
		MovementRecord.recordingManifestPath = nil
		MovementRecord.recordingPendingPath = nil
		MovementRecord.recordingPersistent = false
		MovementRecord.recordingPersistedSampleCount = 0
		MovementRecord.recordingChunkCount = 0
		MovementRecord.recordingChunkBytes = 0
		MovementRecord.recordingFlightLatched = false
		MovementRecord.recordingFlightLastExplicitAt = nil
		MovementRecord.recordingFlightReleaseCount = 0
		MovementRecord.recordingFastFlightCount = 0
	end

	local function updateRecordWindow()
		local ui = MovementRecord.ui
		if not ui or not ui.frame or not ui.frame.Parent then return end
		local modeLabels = {idle = "Ready", recording = "Recording", approaching = "Walking to start", playing = "Playing", looping = "Looping"}
		local elapsedText = "00:00"
		if MovementRecord.mode == "recording" and MovementRecord.startedAt then
			local elapsed = math.max(0, os.clock() - MovementRecord.startedAt)
			elapsedText = string.format("%02d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
		elseif (MovementRecord.mode == "approaching") and MovementRecord.approach and MovementRecord.approach.startedAt then
			local elapsed = math.max(0, os.clock() - MovementRecord.approach.startedAt)
			elapsedText = string.format("%02d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
		elseif (MovementRecord.mode == "playing" or MovementRecord.mode == "looping") and MovementRecord.playbackStartedAt then
			local duration = MovementRecord.saved and (tonumber(MovementRecord.saved.duration) or 0) or 0
			local elapsed = math.max(0, os.clock() - MovementRecord.playbackStartedAt)
			if MovementRecord.playbackLoop and duration > 0 then elapsed = elapsed % duration else elapsed = math.min(elapsed, duration) end
			elapsedText = string.format("%02d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
		end
		ui.status.Text = (modeLabels[MovementRecord.mode] or "Ready") .. "  •  " .. elapsedText
		local savedDuration = MovementRecord.saved and tonumber(MovementRecord.saved.duration) or nil
		ui.saved.Text = savedDuration and string.format("Last: %ds", math.floor(savedDuration + 0.5)) or "Last: None"
		ui.record.Text = MovementRecord.mode == "recording" and "Stop + Save" or "Record"
		ui.play.Active = MovementRecord.saved ~= nil and MovementRecord.mode ~= "recording"
		ui.loop.Active = MovementRecord.saved ~= nil and MovementRecord.mode ~= "recording"
		ui.play.TextTransparency = ui.play.Active and 0 or 0.45
		ui.loop.TextTransparency = ui.loop.Active and 0 or 0.45
	end

	local function hasExternalFlightController(character, root, humanoid, rootVelocity)
		local platformStand = false
		pcall(function() platformStand = humanoid.PlatformStand == true end)
		if platformStand then return true end
		local descendants = nil
		local ok = pcall(function() descendants = character:GetDescendants() end)
		if not ok or type(descendants) ~= "table" then return false end
		local hasOrientationController = false
		for _, item in ipairs(descendants) do
			local className = nil
			pcall(function() className = item.ClassName end)
			if item.Name ~= "IY_CruzanRecordFlightVelocity" and item.Name ~= "IY_CruzanRecordFlightOrientation" and item.Name ~= "IY_CruzanRecordTrajectoryVelocity" then
				if className == "BodyVelocity" then
					local maxForce = Vector3.zero
					pcall(function() maxForce = item.MaxForce end)
					if maxForce and maxForce.Magnitude > 1 then return true end
				elseif className == "LinearVelocity" then
					local enabled, vectorVelocity = true, Vector3.zero
					pcall(function() enabled = item.Enabled ~= false end)
					pcall(function() vectorVelocity = item.VectorVelocity end)
					local forceEnabled = false
					pcall(function() forceEnabled = item.MaxForce > 0 end)
					if enabled and ((vectorVelocity and vectorVelocity.Magnitude > 1) or forceEnabled) then return true end
				elseif className == "VectorForce" or className == "BodyForce" or className == "BodyThrust" then
					local force = Vector3.zero
					pcall(function() force = item.Force end)
					if force and force.Magnitude > 1 then return true end
				elseif className == "BodyGyro" or className == "AlignOrientation" then
					hasOrientationController = true
				end
			end
		end
		return hasOrientationController and rootVelocity and rootVelocity.Magnitude > 20 or false
	end

	local function isBuiltInFlyActive()
		local active = false
		pcall(function() active = FLYING == true end)
		if not active then pcall(function() active = sharedEnv.FLYING == true end) end
		return active
	end

	local function captureFlightControllerSnapshot(character, root, rootVelocity, builtInFly)
		local recordedVelocity, recordedOrientation, bestForce = nil, nil, -1
		local velocityP, gyroP, gyroD = 1250, 1000, 50
		local maxForceVector = Vector3.new(9000000000, 9000000000, 9000000000)
		local maxTorqueVector = Vector3.new(9000000000, 9000000000, 9000000000)
		local descendants = nil
		pcall(function() descendants = root:GetChildren() end)
		if type(descendants) ~= "table" or #descendants == 0 then
			pcall(function() descendants = character:GetDescendants() end)
		end
		for _, item in ipairs(descendants or {}) do
			local className, forceScore = nil, 0
			pcall(function() className = item.ClassName end)
			if item.Name ~= "IY_CruzanRecordFlightVelocity" and item.Name ~= "IY_CruzanRecordFlightOrientation" then
				if className == "BodyVelocity" then
					local value, maxForce = nil, Vector3.zero
					pcall(function() value = item.Velocity end)
					pcall(function() maxForce = item.MaxForce end)
					if value and typeof(value) == "Vector3" then
						forceScore = maxForce and maxForce.Magnitude or 0
						if builtInFly then forceScore = forceScore + 10000000000 end
						if forceScore > bestForce then
							recordedVelocity, bestForce = value, forceScore
							pcall(function() velocityP = tonumber(item.P) or velocityP end)
							if maxForce and maxForce.Magnitude > 1 then maxForceVector = maxForce end
						end
					end
				elseif className == "LinearVelocity" then
					local value, enabled, maxForce = nil, true, 0
					pcall(function() value = item.VectorVelocity end)
					pcall(function() enabled = item.Enabled ~= false end)
					pcall(function() maxForce = tonumber(item.MaxForce) or 0 end)
					if value and typeof(value) == "Vector3" and enabled and (builtInFly or value.Magnitude > 0.1 or maxForce > 1) then
						forceScore = maxForce + (builtInFly and 10000000000 or 0)
						if forceScore > bestForce then
							recordedVelocity, bestForce = value, forceScore
							if maxForce > 1 then maxForceVector = Vector3.new(maxForce, maxForce, maxForce) end
						end
					end
				elseif className == "BodyGyro" or className == "AlignOrientation" then
					local value, maxTorque = nil, nil
					pcall(function() value = item.CFrame end)
					pcall(function() maxTorque = item.MaxTorque end)
					local torqueMagnitude = 0
					if typeof(maxTorque) == "Vector3" then
						torqueMagnitude = maxTorque.Magnitude
					elseif tonumber(maxTorque) then
						torqueMagnitude = tonumber(maxTorque)
					end
					if value and typeof(value) == "CFrame" and (builtInFly or torqueMagnitude > 1) then
						recordedOrientation = value
						pcall(function() gyroP = tonumber(item.P) or gyroP end)
						pcall(function() gyroD = tonumber(item.D) or gyroD end)
						if typeof(maxTorque) == "Vector3" and maxTorque.Magnitude > 1 then
							maxTorqueVector = maxTorque
						elseif tonumber(maxTorque) and tonumber(maxTorque) > 1 then
							maxTorqueVector = Vector3.new(tonumber(maxTorque), tonumber(maxTorque), tonumber(maxTorque))
						end
					end
				end
			end
		end
		if builtInFly then
			pcall(function()
				local camera = workspace.CurrentCamera
				if camera then recordedOrientation = camera.CFrame end
			end)
		end
		if not recordedVelocity then recordedVelocity = rootVelocity end
		if not recordedOrientation then recordedOrientation = root.CFrame end
		return recordedVelocity, recordedOrientation, {
			velocityP = velocityP,
			gyroP = gyroP,
			gyroD = gyroD,
			maxForce = maxForceVector,
			maxTorque = maxTorqueVector,
		}
	end

	local function makeMovementSample(character, humanoid, root, elapsed, previousSample)
		local stateName = getHumanoidStateName(humanoid)
		local moveDirection = Vector3.zero
		pcall(function() moveDirection = humanoid.MoveDirection end)
		local jumpTriggered = MovementRecord.pendingJumpPulse == true
		if not jumpTriggered and stateName == "Jumping" then
			jumpTriggered = not previousSample or previousSample.state ~= "Jumping"
		end
		MovementRecord.pendingJumpPulse = false
		local walkSpeed = 16
		pcall(function() walkSpeed = humanoid.WalkSpeed end)
		local jumpPower, jumpHeight, useJumpPower = 50, 7.2, true
		pcall(function() jumpPower = humanoid.JumpPower end)
		pcall(function() jumpHeight = humanoid.JumpHeight end)
		pcall(function() useJumpPower = humanoid.UseJumpPower end)
		local rootVelocity = Vector3.zero
		pcall(function() rootVelocity = root.AssemblyLinearVelocity end)
		if not rootVelocity or typeof(rootVelocity) ~= "Vector3" then rootVelocity = Vector3.zero end
		local pathVelocity = rootVelocity
		if previousSample and previousSample.cframe and elapsed > (previousSample.t or 0) then
			local dt = elapsed - previousSample.t
			pathVelocity = (root.Position - previousSample.cframe.Position) / dt
		end
		local horizontalSpeed = Vector3.new(pathVelocity.X, 0, pathVelocity.Z).Magnitude
		local jumpingState = stateName == "Jumping"
		local airborneState = jumpingState or stateName == "Freefall" or stateName == "FallingDown" or stateName == "Landed"
		local platformStand = false
		pcall(function() platformStand = humanoid.PlatformStand == true end)
		local builtInFly = isBuiltInFlyActive()
		local hasFlightController = hasExternalFlightController(character, root, humanoid, rootVelocity)
		-- Never classify an ordinary jump's vertical velocity as flight. Only explicit fly/controller
		-- evidence latches flight; the speed-only fallback requires sustained high horizontal motion.
		local explicitFlight = builtInFly or hasFlightController or stateName == "Flying"
			or (platformStand and rootVelocity.Magnitude > 3 and stateName ~= "Jumping" and stateName ~= "Freefall")
		local fastUncommandedMotion = not airborneState and moveDirection.Magnitude < 0.15
			and horizontalSpeed > math.max(48, walkSpeed * 2.7)
		if fastUncommandedMotion then
			MovementRecord.recordingFastFlightCount = (MovementRecord.recordingFastFlightCount or 0) + 1
		else
			MovementRecord.recordingFastFlightCount = 0
		end
		if explicitFlight then
			MovementRecord.recordingFlightLatched = true
			MovementRecord.recordingFlightLastExplicitAt = elapsed
			MovementRecord.recordingFlightReleaseCount = 0
		elseif MovementRecord.recordingFlightLatched then
			local lastExplicitAt = tonumber(MovementRecord.recordingFlightLastExplicitAt) or elapsed
			local groundedState = stateName == "Landed" or stateName == "Running" or stateName == "RunningNoPhysics" or stateName == "GettingUp"
			if groundedState then
				MovementRecord.recordingFlightReleaseCount = (MovementRecord.recordingFlightReleaseCount or 0) + 1
			else
				MovementRecord.recordingFlightReleaseCount = 0
			end
			if (MovementRecord.recordingFlightReleaseCount or 0) >= 4 or elapsed - lastExplicitAt > 0.20 then
				MovementRecord.recordingFlightLatched = false
				MovementRecord.recordingFlightReleaseCount = 0
			end
		end
		local inferredFlight = (MovementRecord.recordingFastFlightCount or 0) >= 3
		local flightMode = explicitFlight or MovementRecord.recordingFlightLatched == true or inferredFlight
		local flightVelocity, flightCFrame, flightControllerProperties = nil, nil, nil
		if flightMode then
			flightVelocity, flightCFrame, flightControllerProperties = captureFlightControllerSnapshot(character, root, rootVelocity, builtInFly)
		end
		return {
			t = elapsed,
			cframe = root.CFrame,
			move = moveDirection,
			jump = jumpTriggered,
			walkSpeed = walkSpeed,
			jumpPower = jumpPower,
			jumpHeight = jumpHeight,
			useJumpPower = useJumpPower,
			state = stateName,
			flight = flightMode,
			flightControl = flightMode and (builtInFly or hasFlightController) or false,
			flightVelocity = flightVelocity,
			flightCFrame = flightCFrame,
			flightVelocityP = flightControllerProperties and flightControllerProperties.velocityP or nil,
			flightGyroP = flightControllerProperties and flightControllerProperties.gyroP or nil,
			flightGyroD = flightControllerProperties and flightControllerProperties.gyroD or nil,
			flightMaxForce = flightControllerProperties and flightControllerProperties.maxForce or nil,
			flightMaxTorque = flightControllerProperties and flightControllerProperties.maxTorque or nil,
			pathVelocity = clampVectorMagnitude(pathVelocity, 160),
		}
	end

	local finishRecording
	local function captureSample(now, finalSample)
		if MovementRecord.mode ~= "recording" then return false end
		local character, humanoid, root = getLocalCharacterParts()
		if character ~= MovementRecord.recordingCharacter or root ~= MovementRecord.recordingRoot or not humanoid then
			if not finalSample and finishRecording then finishRecording(false, "characterChanged", false) end
			return false
		end
		local elapsed = math.max(0, now - (MovementRecord.startedAt or now))
		local samples = MovementRecord.currentSamples
		local previousSample = samples and samples[#samples]
		if not samples then return false end
		if finalSample and previousSample and elapsed <= (previousSample.t or 0) + 0.008 then
			if MovementRecord.pendingJumpPulse then
				previousSample.jump = true
				MovementRecord.pendingJumpPulse = false
			end
			return true
		end
		local sample = makeMovementSample(character, humanoid, root, elapsed, previousSample)
		samples[#samples + 1] = sample
		MovementRecord.lastSampleAt = now
		if not finalSample and MovementRecord.recordingPersistent and #samples - (MovementRecord.recordingPersistedSampleCount or 0) >= RECORD_CHUNK_SIZE then
			local flushed, flushError = flushRecordingChunks(false)
			if not flushed then
				if flushError == "maxBytes" then
					while #samples > (MovementRecord.recordingPersistedSampleCount or 0) do table.remove(samples) end
					if finishRecording then finishRecording(false, "maxBytes", false) end
					return false
				else
					MovementRecord.recordingPersistent = false
					MovementRecord.recordingPersistenceError = tostring(flushError)
					recordNotify("Persistent checkpoint failed; continuing in memory only.", 5)
				end
			end
		end
		if not finalSample and #samples >= MovementRecord.maxMemorySamples then
			if finishRecording then finishRecording(false, "maxSamples", false) end
			return false
		end
		return true
	end

	finishRecording = function(silent, reason, includeFinalSample)
		if MovementRecord.mode ~= "recording" then return false end
		local samples = MovementRecord.currentSamples or {}
		if includeFinalSample ~= false then
			local character, humanoid, root = getLocalCharacterParts()
			if character == MovementRecord.recordingCharacter and root == MovementRecord.recordingRoot and #samples > 0 then
				captureSample(os.clock(), true)
			end
		end
		disconnectRecordingEventConnections()
		if MovementRecord.recordingPersistent then
			local flushed, flushError = flushRecordingChunks(true)
			if not flushed then
				if flushError == "maxBytes" then
					reason = "maxBytes"
					while #samples > (MovementRecord.recordingPersistedSampleCount or 0) do table.remove(samples) end
				else
					MovementRecord.recordingPersistent = false
					MovementRecord.recordingPersistenceError = tostring(flushError)
				end
			end
		end
		MovementRecord.mode = "idle"
		disconnectRecordConnection()
		local duration = #samples > 0 and (samples[#samples].t or 0) or 0
		local valid = #samples >= 2 and duration >= 0.05
		local persistentSaved = false
		local persistentError = MovementRecord.recordingPersistenceError
		if valid then
			MovementRecord.saved = {
				samples = samples,
				duration = duration,
				placeId = MovementRecord.recordingPlaceId or CURRENT_PLACE_ID,
				gameId = MovementRecord.recordingGameId or CURRENT_GAME_ID,
				startCFrame = MovementRecord.recordingStartCFrame or samples[1].cframe,
				version = 4,
				sampleRate = 60,
				movementMode = "humanoid-input-plus-captured-flight-controller",
			}
			if MovementRecord.recordingPersistent then
				local savedOk, savedError = finalizePersistentRecording(MovementRecord.saved)
				persistentSaved = savedOk == true
				persistentError = savedError
			end
			syncSavedRecording()
		elseif MovementRecord.recordingPersistent then
			local pending = readManifest(MovementRecord.recordingPendingPath or "")
			if pending then deleteManifestChunks(pending, MovementRecord.recordingBasePath or "") end
			safeFileDelete(MovementRecord.recordingPendingPath or "")
		end
		local hitByteLimit = reason == "maxBytes"
		local memoryLimit = reason == "maxSamples"
		clearRecordingReferences()
		if not silent then
			if hitByteLimit and valid then
				recordNotify(string.format("The 10 MB recording limit was reached. Saved %.1f seconds (%d samples).", duration, #samples), 5)
			elseif memoryLimit and valid then
				recordNotify(string.format("The in-memory safety limit was reached. Saved %.1f seconds (%d samples).", duration, #samples), 5)
			elseif valid and persistentSaved then
				recordNotify(string.format("Recording saved permanently for this place: %.1f seconds (%d samples).", duration, #samples), 4)
			elseif valid and persistentError then
				recordNotify(string.format("Recording saved for this session only. Disk save failed: %s", tostring(persistentError)), 5)
			elseif valid then
				recordNotify(string.format("Recording saved in memory: %.1f seconds (%d samples). Persistent file access is unavailable.", duration, #samples), 5)
			else
				recordNotify("Recording was too short to save. The previous recording was kept.", 4)
			end
		end
		updateRecordWindow()
		return valid
	end

	local function cancelRecording()
		if MovementRecord.mode ~= "recording" then return false end
		MovementRecord.mode = "idle"
		disconnectRecordConnection()
		if MovementRecord.recordingPersistent then
			local pending = readManifest(MovementRecord.recordingPendingPath or "")
			if pending then deleteManifestChunks(pending, MovementRecord.recordingBasePath or "") end
			safeFileDelete(MovementRecord.recordingPendingPath or "")
		end
		clearRecordingReferences()
		updateRecordWindow()
		return true
	end

	local function unbindPlaybackRenderStep()
		local bindName = MovementRecord.playbackRenderStepName
		MovementRecord.playbackRenderStepName = nil
		if bindName then pcall(function() RunService:UnbindFromRenderStep(bindName) end) end
	end

	local RECORD_NATURAL_START_RADIUS = 22
	local RECORD_APPROACH_TIMEOUT = 10
	local RECORD_APPROACH_ARRIVAL_RADIUS = 1.45
	local RECORD_APPROACH_NEAR_RADIUS = 3.0
	local RECORD_APPROACH_VERTICAL_TOLERANCE = 3.4

	local function removeRecordApproachGyro()
		local gyro = MovementRecord.approachGyro
		MovementRecord.approachGyro = nil
		if gyro then pcall(function() gyro:Destroy() end) end
	end

	-- Remove controllers from the previous playback segment before natural walking begins.
	-- A leftover flight/trajectory mover can fight Humanoid:Move and leave the character jittering in place.
	local function prepareNaturalStartApproach(root, humanoid)
		removeFlightMover()
		removeTrajectoryMover()
		if humanoid then
			pcall(function()
				humanoid.PlatformStand = false
				humanoid.AutoRotate = true
				humanoid.Jump = false
				humanoid:Move(Vector3.zero, false)
			end)
		end
		resetRootVelocity(root)
	end

	local function createNaturalStartApproach(root, humanoid, targetCFrame, resumeElapsed)
		if not root or not humanoid or not targetCFrame then
			return nil
		end
		local targetPosition = targetCFrame.Position
		local offset = targetPosition - root.Position
		local distance = offset.Magnitude
		if distance > RECORD_NATURAL_START_RADIUS then
			return nil
		end
		local horizontalOffset = Vector3.new(offset.X, 0, offset.Z)
		local nearStart = horizontalOffset.Magnitude <= RECORD_APPROACH_NEAR_RADIUS
			and math.abs(offset.Y) <= RECORD_APPROACH_VERTICAL_TOLERANCE
		local arrivalRadius = nearStart and RECORD_APPROACH_NEAR_RADIUS or RECORD_APPROACH_ARRIVAL_RADIUS

		local waypoints = {}
		if not nearStart and distance > RECORD_APPROACH_ARRIVAL_RADIUS then
			local path = nil
			local pathCreated = pcall(function()
				path = PathService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 2.5})
			end)
			if pathCreated and path then
				local computed = pcall(function() path:ComputeAsync(root.Position, targetPosition) end)
				local successStatus = false
				pcall(function() successStatus = path.Status == Enum.PathStatus.Success end)
				if computed and successStatus then
					local okWaypoints, result = pcall(function() return path:GetWaypoints() end)
					if okWaypoints and type(result) == "table" then
						for _, waypoint in ipairs(result) do waypoints[#waypoints + 1] = waypoint end
					end
				end
			end
			if #waypoints > 0 then
				local lastWaypoint = waypoints[#waypoints]
				local lastPosition = nil
				pcall(function() lastPosition = lastWaypoint.Position end)
				if not lastPosition or (lastPosition - targetPosition).Magnitude > 1.5 then
					waypoints[#waypoints + 1] = {Position = targetPosition, Action = Enum.PathWaypointAction.Walk}
				end
			else
				local horizontal = Vector3.new(offset.X, 0, offset.Z)
				-- Safe same-level fallback only; do not walk blindly toward a nearby target across a gap.
				if horizontal.Magnitude <= 12 and math.abs(offset.Y) <= 3.5 then
					waypoints[1] = {Position = targetPosition, Action = Enum.PathWaypointAction.Walk}
				else
					return nil
				end
			end
		end

		local waypointIndex = 1
		if #waypoints > 1 then
			local firstPosition = nil
			pcall(function() firstPosition = waypoints[1].Position end)
			if firstPosition and (firstPosition - root.Position).Magnitude <= 1.6 then waypointIndex = 2 end
		end
		local firstSample = MovementRecord.saved and MovementRecord.saved.samples and MovementRecord.saved.samples[1]
		local walkSpeed = tonumber(firstSample and firstSample.walkSpeed) or tonumber(humanoid.WalkSpeed) or 16
		return {
			targetCFrame = targetCFrame,
			targetPosition = targetPosition,
			waypoints = waypoints,
			waypointIndex = waypointIndex,
			arrivalRadius = arrivalRadius,
			startedAt = os.clock(),
			rotateStartedAt = nil,
			resumeElapsed = tonumber(resumeElapsed) or 0,
			walkSpeed = math.clamp(walkSpeed, 8, 100),
			jumpWaypointIndex = nil,
		}
	end

	-- Pathfinding waypoints are often positioned on the walkable floor, while the
	-- HumanoidRootPart stays several studs above that floor. Match a Walk waypoint
	-- to the current ground plane so that this normal avatar-height offset does not
	-- leave Record repeatedly steering at a waypoint it can never reach vertically.
	local RECORD_APPROACH_GROUND_MATCH_TOLERANCE = 1.25
	local function isGroundAlignedWalkWaypoint(approach, root, humanoid, target, action)
		if not approach or not root or not humanoid or not target or action == Enum.PathWaypointAction.Jump then return false end
		local floorMaterial = Enum.Material.Air
		pcall(function() floorMaterial = humanoid.FloorMaterial end)
		if floorMaterial == Enum.Material.Air then return false end
		if approach.groundRaycastParams == nil then
			local paramsOk, params = pcall(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {MovementRecord.playbackCharacter or root.Parent}
				raycastParams.IgnoreWater = true
				return raycastParams
			end)
			approach.groundRaycastParams = paramsOk and params or false
		end
		local raycastParams = approach.groundRaycastParams
		if not raycastParams then return false end
		local groundHit = nil
		local rayOk = pcall(function()
			groundHit = workspace:Raycast(root.Position, Vector3.new(0, -12, 0), raycastParams)
		end)
		if not rayOk or not groundHit then return false end
		local rootGroundOffset = root.Position.Y - groundHit.Position.Y
		local waypointGroundOffset = root.Position.Y - target.Y
		local groundDifference = math.abs(rootGroundOffset - waypointGroundOffset)
		return rootGroundOffset >= 0 and groundDifference <= RECORD_APPROACH_GROUND_MATCH_TOLERANCE, rootGroundOffset, waypointGroundOffset, groundDifference
	end

	local function stepNaturalStartApproach()
		local approach = MovementRecord.approach
		local humanoid = MovementRecord.playbackHumanoid
		local root = MovementRecord.playbackRoot
		if not approach or not humanoid or not root or not root.Parent then return false, "The character is no longer available while approaching the start." end
		local now = os.clock()
		if now - (approach.startedAt or now) > RECORD_APPROACH_TIMEOUT then
			return false, "Could not reach the recording start naturally before timeout."
		end
		local waypoints = approach.waypoints or {}
		local arrivalRadius = tonumber(approach.arrivalRadius) or RECORD_APPROACH_ARRIVAL_RADIUS
		local index = tonumber(approach.waypointIndex) or 1
		local waypoint = waypoints[index]
		if waypoint then
			local target = nil
			local action = nil
			pcall(function() target = waypoint.Position; action = waypoint.Action end)
			if target then
				local offset = target - root.Position
				local horizontal = Vector3.new(offset.X, 0, offset.Z)
				local waypointReached = horizontal.Magnitude <= arrivalRadius and math.abs(offset.Y) <= RECORD_APPROACH_VERTICAL_TOLERANCE
				if not waypointReached and horizontal.Magnitude <= arrivalRadius then
					local groundMatched = isGroundAlignedWalkWaypoint(approach, root, humanoid, target, action)
					if groundMatched then
						waypointReached = true
					end
				end
				if waypointReached then
					approach.waypointIndex = index + 1
					pcall(function() humanoid:Move(Vector3.zero, false) end)
					return true, "working"
				end
				if action == Enum.PathWaypointAction.Jump and approach.jumpWaypointIndex ~= index then
					approach.jumpWaypointIndex = index
					pcall(function() humanoid.Jump = true end)
					pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
				end
				pcall(function() humanoid.AutoRotate = true end)
				pcall(function() humanoid.WalkSpeed = approach.walkSpeed end)
				local direction = horizontal.Magnitude > 0.05 and horizontal.Unit or Vector3.zero
				local moveOk = pcall(function() humanoid:Move(direction, false) end)
				if not moveOk then return false, "Humanoid movement input failed while approaching the start." end
				return true, "working"
			end
		end

		local finalOffset = approach.targetPosition - root.Position
		local finalHorizontal = Vector3.new(finalOffset.X, 0, finalOffset.Z)
		if finalHorizontal.Magnitude > arrivalRadius or math.abs(finalOffset.Y) > RECORD_APPROACH_VERTICAL_TOLERANCE then
			local direction = finalHorizontal.Magnitude > 0.05 and finalHorizontal.Unit or Vector3.zero
			pcall(function() humanoid.AutoRotate = true; humanoid.WalkSpeed = approach.walkSpeed; humanoid:Move(direction, false) end)
			return true, "working"
		end

		pcall(function() humanoid:Move(Vector3.zero, false); humanoid.AutoRotate = false end)
		if not MovementRecord.approachGyro then
			local targetLook = approach.targetCFrame.LookVector
			local horizontalLook = Vector3.new(targetLook.X, 0, targetLook.Z)
			if horizontalLook.Magnitude < 0.001 then horizontalLook = Vector3.new(0, 0, -1) else horizontalLook = horizontalLook.Unit end
			local targetRotation = CFrame.lookAt(root.Position, root.Position + horizontalLook, Vector3.yAxis)
			local ok, gyro = pcall(function()
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.Name = "IY_CruzanRecordStartAlignment"
				bodyGyro.P = 3200
				bodyGyro.D = 180
				bodyGyro.MaxTorque = Vector3.new(0, 900000000, 0)
				bodyGyro.CFrame = targetRotation
				bodyGyro.Parent = root
				return bodyGyro
			end)
			if ok then MovementRecord.approachGyro = gyro end
			approach.rotateStartedAt = now
		end
		local targetLook = approach.targetCFrame.LookVector
		local currentLook = root.CFrame.LookVector
		local targetFlat = Vector3.new(targetLook.X, 0, targetLook.Z)
		local currentFlat = Vector3.new(currentLook.X, 0, currentLook.Z)
		local aligned = false
		if targetFlat.Magnitude > 0.001 and currentFlat.Magnitude > 0.001 then
			aligned = targetFlat.Unit:Dot(currentFlat.Unit) >= 0.9925
		end
		if aligned or now - (approach.rotateStartedAt or now) >= 1.35 then
			removeRecordApproachGyro()
			local original = MovementRecord.originalProperties
			pcall(function() humanoid.AutoRotate = not original or original.autoRotate ~= false; humanoid:Move(Vector3.zero, false) end)
			MovementRecord.approach = nil
			return true, "done"
		end
		return true, "working"
	end

	local function restorePlaybackProperties()
		unbindPlaybackRenderStep()
		removeRecordApproachGyro()
		MovementRecord.approach = nil
		local humanoid = MovementRecord.playbackHumanoid
		local original = MovementRecord.originalProperties
		if humanoid and original then
			pcall(function() humanoid.WalkSpeed = original.walkSpeed end)
			pcall(function() humanoid.JumpPower = original.jumpPower end)
			pcall(function() humanoid.JumpHeight = original.jumpHeight end)
			pcall(function() humanoid.UseJumpPower = original.useJumpPower end)
			pcall(function() humanoid.PlatformStand = original.platformStand == true end)
			pcall(function() humanoid.AutoRotate = original.autoRotate ~= false end)
			pcall(function() humanoid.Jump = false end)
			pcall(function() humanoid:Move(Vector3.zero, false) end)
		end
		MovementRecord.originalProperties = nil
		MovementRecord.playbackJumpResetPending = false
		MovementRecord.playbackJumpPendingUntil = nil
		MovementRecord.playbackJumpLastAttemptAt = 0
		MovementRecord.playbackJumpLastAttemptElapsed = nil
		MovementRecord.playbackLastSampleIndex = 0
		local controls = MovementRecord.controls
		MovementRecord.controls = nil
		if controls then pcall(function() controls:Enable() end) end
		removeFlightMover()
		removeTrajectoryMover()
	end

	local function stopPlayback(silent, zeroVelocity, stopReason)
		if MovementRecord.mode ~= "playing" and MovementRecord.mode ~= "looping" and MovementRecord.mode ~= "approaching" then return false end
		local root = MovementRecord.playbackRoot
		MovementRecord.mode = "idle"
		disconnectRecordConnection()
		restorePlaybackProperties()
		MovementRecord.playbackCharacter = nil
		MovementRecord.playbackHumanoid = nil
		MovementRecord.playbackRoot = nil
		MovementRecord.playbackStartedAt = nil
		MovementRecord.playbackCurrentElapsed = nil
		MovementRecord.playbackLoop = false
		MovementRecord.playbackLastElapsed = 0
		if zeroVelocity then resetRootVelocity(root) end
		if not silent then recordNotify("Playback stopped.") end
		updateRecordWindow()
		return true
	end

	local function disableDefaultControls()
		-- PlayerModule is optional: some executors/games do not expose it to this script.
		-- If it is missing, playback still runs and applies Humanoid movement after the default input step.
		MovementRecord.controlsFallback = false
		local player = Players.LocalPlayer
		local playerScripts = player and (player:FindFirstChild("PlayerScripts") or player.PlayerScripts)
		local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
		if not playerModule and playerScripts then
			pcall(function() playerModule = playerScripts:WaitForChild("PlayerModule", 0.75) end)
		end
		local function useFallback(reason)
			MovementRecord.controls = nil
			MovementRecord.controlsFallback = true
			return true, tostring(reason or "PlayerModule is not available")
		end
		if not playerModule then return useFallback("PlayerModule is not available") end
		local loaded, module = pcall(require, playerModule)
		if not loaded or type(module) ~= "table" or type(module.GetControls) ~= "function" then
			return useFallback("PlayerModule controls could not be loaded")
		end
		local ok, controls = pcall(function() return module:GetControls() end)
		if not ok or not controls or type(controls.Disable) ~= "function" or type(controls.Enable) ~= "function" then
			return useFallback("PlayerModule controls cannot be disabled")
		end
		local disabled = pcall(function() controls:Disable() end)
		if not disabled then return useFallback("PlayerModule controls failed to disable") end
		MovementRecord.controls = controls
		return true, nil
	end

	local function removeFlightMoverOnPlaybackStart()
		removeFlightMover()
	end

	local function getSampleAt(saved, elapsed)
		local samples = saved.samples
		local low, high, found = 1, #samples, 1
		while low <= high do
			local mid = math.floor((low + high) / 2)
			if (tonumber(samples[mid].t) or 0) <= elapsed then
				found = mid
				low = mid + 1
			else
				high = mid - 1
			end
		end
		return samples[found], samples[math.min(found + 1, #samples)], found
	end

	local function deriveHorizontalMove(a, b)
		if not a or not b or not a.cframe or not b.cframe then return Vector3.zero end
		local delta = b.cframe.Position - a.cframe.Position
		local horizontal = Vector3.new(delta.X, 0, delta.Z)
		return horizontal.Magnitude > 0.05 and horizontal.Unit or Vector3.zero
	end

	local function getTargetPosition(saved, elapsed)
		local a, b = getSampleAt(saved, elapsed)
		if not a or not a.cframe then return nil end
		if not b or not b.cframe then return a.cframe.Position end
		local span = (tonumber(b.t) or 0) - (tonumber(a.t) or 0)
		local alpha = span > 0 and math.clamp((elapsed - (tonumber(a.t) or 0)) / span, 0, 1) or 0
		return a.cframe.Position:Lerp(b.cframe.Position, alpha)
	end

	local function applyPlaybackAt(elapsed)
		local saved = MovementRecord.saved
		if not saved or type(saved.samples) ~= "table" or #saved.samples < 2 then return false, "No usable recording. Run record to open the controls, then record a path." end
		local duration = tonumber(saved.duration) or 0
		if duration < 0.05 then return false, "The saved recording is too short." end
		local localElapsed = elapsed
		if MovementRecord.playbackLoop then
			localElapsed = elapsed % duration
			if localElapsed < (MovementRecord.playbackLastElapsed or 0) then
				MovementRecord.lastJump = false
				MovementRecord.playbackLastSampleIndex = 0
			end
		elseif elapsed >= duration then
			stopPlayback(true, true, "single playback finished")
			recordNotify("Playback finished.", 4)
			return false, "finished"
		end
		local a, b, sampleIndex = getSampleAt(saved, localElapsed)
		if not a then return false, "Invalid sample data." end
		local humanoid = MovementRecord.playbackHumanoid
		local root = MovementRecord.playbackRoot
		if not humanoid or not root or not root.Parent then return false, "Character root is no longer available." end
		-- Release the previous one-frame jump pulse before processing any new jump event.
		if MovementRecord.playbackJumpResetPending then
			pcall(function() humanoid.Jump = false end)
			MovementRecord.playbackJumpResetPending = false
		end
		-- Process every crossed sample so a short jump marker cannot be skipped by a delayed frame.
		local lastSampleIndex = tonumber(MovementRecord.playbackLastSampleIndex) or 0
		if sampleIndex < lastSampleIndex then lastSampleIndex = 0 end
		local jumpEventFound = false
		for index = math.max(1, lastSampleIndex + 1), sampleIndex do
			local candidate = saved.samples[index]
			if candidate and candidate.jump == true and candidate.flight ~= true then
				local prior = saved.samples[index - 1]
				if not prior or prior.jump ~= true then jumpEventFound = true end
			end
		end
		MovementRecord.playbackLastSampleIndex = sampleIndex
		MovementRecord.playbackLastElapsed = localElapsed
		local sampleMove = a.move
		if not sampleMove or sampleMove.Magnitude < 0.08 then sampleMove = deriveHorizontalMove(a, b) end
		local isFlight = a.flight == true
		local recordedSpeed = tonumber(a.walkSpeed) or 16
		local segmentVelocity = nil
		if b and b.cframe and a.cframe then
			local span = (tonumber(b.t) or 0) - (tonumber(a.t) or 0)
			if span > 0 then segmentVelocity = (b.cframe.Position - a.cframe.Position) / span end
		end
		-- Older in-session recordings only have CFrames; infer clear airborne/fast segments for a best-effort migration.
		if a.flight == nil and segmentVelocity then
			local segmentHorizontalSpeed = Vector3.new(segmentVelocity.X, 0, segmentVelocity.Z).Magnitude
			if segmentHorizontalSpeed > math.max(25, recordedSpeed * 1.55) or math.abs(segmentVelocity.Y) > math.max(8, recordedSpeed * 0.6) then
				isFlight = true
			end
		end
		-- Preserve jump events until the Humanoid accepts them. A small timing/landing difference
		-- should not silently drop a parkour jump after recording playback starts drifting.
		if jumpEventFound and not isFlight then
			MovementRecord.playbackJumpPendingUntil = math.max(tonumber(MovementRecord.playbackJumpPendingUntil) or 0, localElapsed + 0.38)
		end
		local currentStateName = getHumanoidStateName(humanoid)
		if not isFlight and MovementRecord.playbackJumpPendingUntil then
			local rootVelocityNow = Vector3.zero
			local floorMaterial = nil
			pcall(function() rootVelocityNow = root.AssemblyLinearVelocity end)
			pcall(function() floorMaterial = humanoid.FloorMaterial end)
			local airborneNow = currentStateName == "Jumping" or (floorMaterial == Enum.Material.Air and rootVelocityNow.Y > 4)
			if airborneNow then
				MovementRecord.playbackJumpPendingUntil = nil
				MovementRecord.playbackJumpResetPending = true
			elseif localElapsed <= MovementRecord.playbackJumpPendingUntil then
				local groundedNow = floorMaterial ~= Enum.Material.Air or currentStateName == "Running" or currentStateName == "Landed" or currentStateName == "RunningNoPhysics"
				local lastJumpAttemptElapsed = tonumber(MovementRecord.playbackJumpLastAttemptElapsed)
				if groundedNow and (lastJumpAttemptElapsed == nil or localElapsed - lastJumpAttemptElapsed >= 0.045) then
					pcall(function() humanoid.Jump = true end)
					pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
					MovementRecord.playbackJumpLastAttemptAt = os.clock()
					MovementRecord.playbackJumpLastAttemptElapsed = localElapsed
					MovementRecord.playbackJumpResetPending = true
				end
			else
				MovementRecord.playbackJumpPendingUntil = nil
			end
		end
		if isFlight then
			removeTrajectoryMover()
			local mover = ensureFlightMover(root)
			if not mover then return false, "Could not create the flight physics controller." end
			local velocity = a.flightControl and a.flightVelocity or a.pathVelocity
			if velocity == nil and segmentVelocity then velocity = segmentVelocity end
			if not velocity or typeof(velocity) ~= "Vector3" then velocity = root.AssemblyLinearVelocity or Vector3.zero end
			if not velocity or typeof(velocity) ~= "Vector3" then velocity = Vector3.zero end
			local gyro = MovementRecord.flightGyro
			if a.flightControl then
				pcall(function()
					mover.P = math.clamp(tonumber(a.flightVelocityP) or 1250, 100, 200000)
					local force = a.flightMaxForce
					if force and typeof(force) == "Vector3" and force.Magnitude > 1 then mover.MaxForce = force end
				end)
				pcall(function()
					if gyro then
						gyro.P = math.clamp(tonumber(a.flightGyroP) or 1000, 100, 200000)
						gyro.D = math.max(0, math.min(tonumber(a.flightGyroD) or 50, 50000))
						local torque = a.flightMaxTorque
						if torque and typeof(torque) == "Vector3" and torque.Magnitude > 1 then gyro.MaxTorque = torque end
					end
				end)
			end
			-- Track the recorded 3D path continuously. The source fly velocity remains a useful fallback,
			-- but using only controller velocity can drift after a delayed frame or network correction.
			local targetNow = getTargetPosition(saved, localElapsed)
			local lookAheadTime = math.min(duration, localElapsed + 0.06)
			local targetAhead = getTargetPosition(saved, lookAheadTime)
			local routeVelocity = segmentVelocity
			if targetNow and targetAhead and lookAheadTime > localElapsed + 0.001 then
				routeVelocity = (targetAhead - targetNow) / (lookAheadTime - localElapsed)
			end
			local sourceVelocity = a.flightControl and a.flightVelocity or nil
			if routeVelocity and typeof(routeVelocity) == "Vector3" and routeVelocity.Magnitude > 1 then
				-- The captured world path is authoritative; controller velocity is only a fallback
				-- when adjacent samples are nearly stationary or missing.
				velocity = routeVelocity
			elseif sourceVelocity and typeof(sourceVelocity) == "Vector3" then
				velocity = sourceVelocity
			elseif routeVelocity and typeof(routeVelocity) == "Vector3" then
				velocity = routeVelocity
			end
			if targetNow then
				local positionError = targetNow - root.Position
				local correction = clampVectorMagnitude(positionError * 5.0, 45)
				velocity = velocity + correction
			end
			mover.Velocity = clampVectorMagnitude(velocity, 5000)
			local orientationCFrame = a.flightCFrame or a.cframe
			if gyro and orientationCFrame then
				-- Built-in fly uses the camera orientation; replay the captured orientation and source gyro gains.
				pcall(function() gyro.CFrame = CFrame.new(root.Position) * orientationCFrame.Rotation end)
			end
			pcall(function() humanoid.PlatformStand = true end)
			pcall(function() humanoid.AutoRotate = false end)
			pcall(function() humanoid:Move(Vector3.zero, false) end)
		else
			removeFlightMover()
			local original = MovementRecord.originalProperties
			if original then
				pcall(function() humanoid.PlatformStand = original.platformStand == true end)
				pcall(function() humanoid.AutoRotate = original.autoRotate ~= false end)
			end
			local aState = tostring(a.state or "")
			local bState = tostring(b and b.state or "")
			local function isRecordedAirState(state)
				return state == "Jumping" or state == "Freefall" or state == "FallingDown" or state == "Ragdoll"
			end
			local recordedAirborne = a.jump == true or isRecordedAirState(aState)
			if not recordedAirborne and segmentVelocity and isRecordedAirState(bState) then recordedAirborne = true end
			if recordedAirborne then
				-- Parkour gaps are sensitive to a few frames of drift. Track the recorded 3D trajectory
				-- with a physics velocity actuator only during recorded airborne frames; never teleport each sample.
				local trajectoryMover = ensureTrajectoryMover(root)
				if not trajectoryMover then return false, "Could not create the parkour trajectory controller." end
				local targetNow = getTargetPosition(saved, localElapsed)
				local lookAheadTime = math.min(duration, localElapsed + 0.06)
				local targetAhead = getTargetPosition(saved, lookAheadTime)
				local routeVelocity = segmentVelocity or Vector3.zero
				if targetNow and targetAhead and lookAheadTime > localElapsed + 0.001 then
					routeVelocity = (targetAhead - targetNow) / (lookAheadTime - localElapsed)
				end
				if not routeVelocity or typeof(routeVelocity) ~= "Vector3" then routeVelocity = Vector3.zero end
				if targetNow then
					local positionError = targetNow - root.Position
					local correction = clampVectorMagnitude(positionError * 6.0, 38)
					routeVelocity = routeVelocity + correction
				end
				trajectoryMover.P = 18000
				trajectoryMover.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
				trajectoryMover.Velocity = clampVectorMagnitude(routeVelocity, 260)
			else
				removeTrajectoryMover()
				local targetPosition = getTargetPosition(saved, math.min(duration, localElapsed + 0.12))
				if targetPosition then
					local offset = targetPosition - root.Position
					local horizontalOffset = Vector3.new(offset.X, 0, offset.Z)
					-- Small, continuous ground steering correction complements direct Humanoid input.
					if horizontalOffset.Magnitude > 0.55 then
						local correction = horizontalOffset.Unit
						local correctionWeight = math.clamp((horizontalOffset.Magnitude - 0.45) / 2.0, 0.08, 0.82)
						if sampleMove and sampleMove.Magnitude > 0.08 then
							sampleMove = sampleMove.Unit:Lerp(correction, correctionWeight)
							if sampleMove.Magnitude > 0.05 then sampleMove = sampleMove.Unit end
						else
							sampleMove = correction
						end
					end
				end
			end
			local desiredWalkSpeed = tonumber(a.walkSpeed)
			if desiredWalkSpeed and desiredWalkSpeed > 0 then pcall(function() humanoid.WalkSpeed = math.min(desiredWalkSpeed, 100) end) end
			if a.useJumpPower ~= nil then pcall(function() humanoid.UseJumpPower = a.useJumpPower end) end
			local desiredJumpPower = tonumber(a.jumpPower)
			local desiredJumpHeight = tonumber(a.jumpHeight)
			if desiredJumpPower and desiredJumpPower > 0 then pcall(function() humanoid.JumpPower = math.min(desiredJumpPower, 200) end) end
			if desiredJumpHeight and desiredJumpHeight > 0 then pcall(function() humanoid.JumpHeight = math.min(desiredJumpHeight, 100) end) end
			local moved = pcall(function() humanoid:Move(sampleMove or Vector3.zero, false) end)
			if not moved then return false, "Humanoid movement input failed." end
		end
		return true
	end

	MovementRecord.ApplyPlaybackAt = applyPlaybackAt
	MovementRecord.CaptureSample = captureSample

	local function startRecording(silent)
		if MovementRecord.mode == "recording" then
			if not silent then recordNotify("Already recording. Use Stop to save the current route.") end
			updateRecordWindow()
			return false
		end
		if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true) end
		local character, humanoid, root = getLocalCharacterParts()
		if not character or not humanoid or not root then
			if not silent then recordNotify("Cannot record: your character is not ready.") end
			return false
		end
		disconnectRecordConnection()
		MovementRecord.mode = "recording"
		MovementRecord.currentSamples = {}
		MovementRecord.startedAt = os.clock()
		MovementRecord.lastSampleAt = nil
		MovementRecord.recordingCharacter = character
		MovementRecord.recordingRoot = root
		MovementRecord.recordingHumanoid = humanoid
		MovementRecord.recordingGameId = CURRENT_GAME_ID
		MovementRecord.recordingPlaceId = CURRENT_PLACE_ID
		MovementRecord.recordingStartCFrame = root.CFrame
		MovementRecord.recordingSessionId = pathToken((function()
			local ok, guid = pcall(function() return HttpService:GenerateGUID(false) end)
			return ok and guid or (tostring(os.time()) .. tostring(math.floor(os.clock() * 100000)))
		end)())
		local paths = recordPaths(CURRENT_GAME_ID, CURRENT_PLACE_ID)
		MovementRecord.recordingBasePath = paths.base
		MovementRecord.recordingManifestPath = paths.manifest
		MovementRecord.recordingPendingPath = paths.pending
		MovementRecord.recordingPersistent = ensureRecordFolder()
		MovementRecord.recordingPersistedSampleCount = 0
		MovementRecord.recordingChunkCount = 0
		MovementRecord.recordingChunkBytes = 0
		MovementRecord.recordingPersistenceError = MovementRecord.recordingPersistent and nil or "Executor file APIs are unavailable."
		if MovementRecord.recordingPersistent then
			local stalePending = readManifest(paths.pending)
			if stalePending and stalePending.sessionId ~= MovementRecord.recordingSessionId then deleteManifestChunks(stalePending, paths.base) end
			local initialManifest = activeManifest(0, 0, false)
			local pendingRaw = safeJsonEncode(initialManifest)
			local pendingWritten = pendingRaw and safeFileWrite(paths.pending, pendingRaw)
			if not pendingWritten then
				MovementRecord.recordingPersistent = false
				MovementRecord.recordingPersistenceError = "Could not create the checkpoint manifest."
			end
		end
		MovementRecord.recordingEventConnections = {}
		MovementRecord.pendingJumpPulse = false
		MovementRecord.recordingFlightLatched = false
		MovementRecord.recordingFlightLastExplicitAt = nil
		MovementRecord.recordingFlightReleaseCount = 0
		MovementRecord.recordingFastFlightCount = 0
		local function queueRecordedJump()
			if MovementRecord.mode == "recording" and MovementRecord.recordingHumanoid == humanoid then
				MovementRecord.pendingJumpPulse = true
			end
		end
		local stateSignalOk, stateConnection = pcall(function()
			return humanoid.StateChanged:Connect(function(_, newState)
				if newState == Enum.HumanoidStateType.Jumping then queueRecordedJump() end
			end)
		end)
		if stateSignalOk then trackRecordingEventConnection(stateConnection) end
		local jumpSignalOk, jumpConnection = pcall(function()
			return humanoid.Jumping:Connect(function(active)
				if active then queueRecordedJump() end
			end)
		end)
		if jumpSignalOk then trackRecordingEventConnection(jumpConnection) end
		captureSample(MovementRecord.startedAt, true)
		local sampleAccumulator = 0
		local lastHeartbeatClock = MovementRecord.startedAt
		local connection = RunService.Heartbeat:Connect(function(dt)
			if MovementRecord.mode ~= "recording" then return end
			local now = os.clock()
			local frameDelta = tonumber(dt)
			if not frameDelta or frameDelta <= 0 then frameDelta = math.max(0, now - (lastHeartbeatClock or now)) end
			lastHeartbeatClock = now
			sampleAccumulator = sampleAccumulator + math.max(0, frameDelta)
			-- Accumulate frame time so tiny floating-point timing differences do not halve the 60 Hz target.
			if sampleAccumulator + 0.000001 >= MovementRecord.sampleInterval then
				sampleAccumulator = sampleAccumulator % MovementRecord.sampleInterval
				captureSample(now, false)
			end
		end)
		MovementRecord.connection = connection
		if IY_RELOAD_INSTANCE_STATE and type(IY_RELOAD_INSTANCE_STATE.TrackConnection) == "function" then
			IY_RELOAD_INSTANCE_STATE.TrackConnection(connection)
		end
		if not silent then
			if MovementRecord.recordingPersistent then
				recordNotify("Recording started at 60 Hz. Checkpoints are saved locally for this game/place.", 4)
			else
				recordNotify("Recording started at 60 Hz. Local file storage is unavailable; this recording is session-only.", 5)
			end
		end
		updateRecordWindow()
		return true
	end

	local function startPlayback(looping, silent)
		refreshSavedRecording()
		local saved = MovementRecord.saved
		if not saved or type(saved.samples) ~= "table" or #saved.samples < 2 then
			if not silent then recordNotify("No saved movement. Use record to open the window and record a path.") end
			return false
		end
		if tonumber(saved.placeId) ~= CURRENT_PLACE_ID or (saved.gameId ~= nil and tostring(saved.gameId) ~= CURRENT_GAME_ID) then
			if not silent then recordNotify("This recording belongs to a different game or place. Playback was blocked.", 4) end
			return false
		end
		local character, humanoid, root = getLocalCharacterParts()
		if not character or not humanoid or not root then
			if not silent then recordNotify("Cannot play: your character is not ready.") end
			return false
		end
		if MovementRecord.mode == "recording" then
			finishRecording(true, "stopped", true)
			refreshSavedRecording()
			saved = MovementRecord.saved
			if not saved or type(saved.samples) ~= "table" or #saved.samples < 2 then
				if not silent then recordNotify("The recording did not contain a usable path.") end
				return false
			end
		end
		if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true, "restarted by new playback request") end
		local first = saved.samples[1]
		local startCFrame = saved.startCFrame or (first and first.cframe)
		if not startCFrame then
			if not silent then recordNotify("The recording has no valid starting position.", 4) end
			return false
		end
		local recordingHasFlight = false
		for _, sample in ipairs(saved.samples) do
			if sample and sample.flight == true then recordingHasFlight = true; break end
		end
		-- Infinite Yield's desktop/mobile fly controllers keep updating their own BodyVelocity/BodyGyro.
		-- Stop those before playback so their live input cannot fight the recorded flight samples.
		if recordingHasFlight and isBuiltInFlyActive() then
			local stopFly = IY_RELOAD_INSTANCE_STATE and IY_RELOAD_INSTANCE_STATE.stopFlyForRecordPlayback
			if type(stopFly) == "function" then
				local stopOk, stopped = pcall(stopFly)
				if not stopOk or stopped == false or isBuiltInFlyActive() then
					if not silent then recordNotify("Playback blocked: could not suspend the active fly controller. Use unfly and try again.", 5) end
					return false
				end
			else
				if not silent then recordNotify("Playback blocked: the active fly controller is still running. Use unfly and try again.", 5) end
				return false
			end
		end
		local controlsOk = disableDefaultControls()
		-- Do not block playback if PlayerModule is hidden. A render-step fallback reapplies
		-- Humanoid:Move after default input processing so walking/jumping can still run naturally.
		if not controlsOk then
			MovementRecord.controlsFallback = true
		end
		MovementRecord.originalProperties = {
			walkSpeed = humanoid.WalkSpeed,
			jumpPower = humanoid.JumpPower,
			jumpHeight = humanoid.JumpHeight,
			useJumpPower = humanoid.UseJumpPower,
			platformStand = humanoid.PlatformStand,
			autoRotate = humanoid.AutoRotate,
		}
		local approach = createNaturalStartApproach(root, humanoid, startCFrame, 0)
		local startPositioned = true
		if approach then
			prepareNaturalStartApproach(root, humanoid)
		else
			-- Clear any controller left by an interrupted segment before the one-time reposition fallback.
			removeFlightMover()
			removeTrajectoryMover()
			startPositioned = pcall(function()
				root.CFrame = startCFrame -- Far or unreachable starts retain the existing one-time reposition fallback.
				resetRootVelocity(root)
			end)
		end
		if not startPositioned then
			restorePlaybackProperties()
			if not silent then recordNotify("Could not return to the recorded starting position.", 5) end
			return false
		end
		MovementRecord.approach = approach
		MovementRecord.mode = approach and "approaching" or (looping and "looping" or "playing")
		MovementRecord.playbackLoop = looping == true
		MovementRecord.playbackCharacter = character
		MovementRecord.playbackHumanoid = humanoid
		MovementRecord.playbackRoot = root
		MovementRecord.playbackStartedAt = approach and nil or os.clock()
		MovementRecord.playbackCurrentElapsed = 0
		MovementRecord.playbackLastElapsed = 0
		MovementRecord.playbackLastSampleIndex = 0
		MovementRecord.playbackJumpResetPending = false
		MovementRecord.playbackJumpPendingUntil = nil
		MovementRecord.playbackJumpLastAttemptAt = 0
		MovementRecord.playbackJumpLastAttemptElapsed = nil
		MovementRecord.playbackLoopIndex = 0
		MovementRecord.lastJump = false
		removeFlightMoverOnPlaybackStart()
		local function advanceNaturalStartApproach()
			local resumeElapsed = MovementRecord.approach and tonumber(MovementRecord.approach.resumeElapsed) or 0
			local approachOk, approachState = stepNaturalStartApproach()
			if not approachOk then
				stopPlayback(true, true, "natural approach failed: " .. tostring(approachState))
				recordNotify("Could not approach the recorded start: " .. tostring(approachState), 5)
				return false
			end
			if approachState == "done" then
				MovementRecord.mode = MovementRecord.playbackLoop and "looping" or "playing"
				MovementRecord.playbackStartedAt = os.clock() - resumeElapsed
				MovementRecord.playbackCurrentElapsed = resumeElapsed
				MovementRecord.playbackLastElapsed = 0
				MovementRecord.playbackLastSampleIndex = 0
				MovementRecord.playbackJumpPendingUntil = nil
				MovementRecord.playbackJumpLastAttemptAt = 0
				MovementRecord.playbackJumpLastAttemptElapsed = nil
				MovementRecord.lastJump = false
				updateRecordWindow()
			end
			return true
		end
		local connection = RunService.Heartbeat:Connect(function()
			if MovementRecord.mode ~= "playing" and MovementRecord.mode ~= "looping" and MovementRecord.mode ~= "approaching" then return end
			local currentCharacter, currentHumanoid, currentRoot = getLocalCharacterParts()
			if currentCharacter ~= MovementRecord.playbackCharacter or currentRoot ~= MovementRecord.playbackRoot or not currentHumanoid then
				stopPlayback(true, false, "character changed or died")
				recordNotify("Playback stopped because your character changed or died.", 4)
				return
			end
			if MovementRecord.mode == "approaching" then
				-- If default controls remain active, let the post-input RenderStep handler
				-- issue movement so PlayerModule cannot overwrite it later in the frame.
				if not (MovementRecord.controlsFallback and MovementRecord.playbackRenderStepName) then
					advanceNaturalStartApproach()
				end
				return
			end
			local elapsed = os.clock() - (MovementRecord.playbackStartedAt or os.clock())
			MovementRecord.playbackCurrentElapsed = elapsed
			if MovementRecord.playbackLoop then
				local loopDuration = tonumber(MovementRecord.saved and MovementRecord.saved.duration) or 0
				local loopIndex = loopDuration > 0 and math.floor(elapsed / loopDuration) or 0
				if loopIndex > (MovementRecord.playbackLoopIndex or 0) then
					local loopStart = MovementRecord.saved and (MovementRecord.saved.startCFrame or (MovementRecord.saved.samples[1] and MovementRecord.saved.samples[1].cframe))
					local loopApproach = loopStart and createNaturalStartApproach(currentRoot, currentHumanoid, loopStart, loopIndex * loopDuration)
					if loopApproach then
						-- Release the previous iteration's physics controllers before approaching on foot.
						prepareNaturalStartApproach(currentRoot, currentHumanoid)
						MovementRecord.approach = loopApproach
						MovementRecord.mode = "approaching"
						MovementRecord.playbackLoopIndex = loopIndex
						MovementRecord.playbackLastElapsed = 0
						MovementRecord.playbackJumpPendingUntil = nil
						MovementRecord.playbackJumpLastAttemptAt = 0
						MovementRecord.playbackJumpLastAttemptElapsed = nil
						MovementRecord.lastJump = false
						updateRecordWindow()
						return
					end
					-- If natural walking is unavailable, clear old movers before the one-time fallback.
					removeFlightMover()
					removeTrajectoryMover()
					local resetOk = loopStart and pcall(function()
						currentHumanoid.PlatformStand = false
						currentHumanoid.Jump = false
						currentHumanoid:Move(Vector3.zero, false)
						currentRoot.CFrame = loopStart
						resetRootVelocity(currentRoot)
					end)
					if not resetOk then
						stopPlayback(true, false, "loop start position could not be restored")
						recordNotify("Loop stopped because the starting position could not be restored.", 4)
						return
					end
					MovementRecord.playbackStartedAt = os.clock() - loopIndex * loopDuration
					MovementRecord.playbackLoopIndex = loopIndex
					MovementRecord.playbackLastElapsed = 0
					MovementRecord.playbackJumpPendingUntil = nil
					MovementRecord.playbackJumpLastAttemptAt = 0
					MovementRecord.playbackJumpLastAttemptElapsed = nil
					MovementRecord.lastJump = false
				end
			end
			local ok, err = applyPlaybackAt(elapsed)
			if not ok and err ~= "finished" then
				stopPlayback(true, false, "applyPlaybackAt failed: " .. tostring(err))
				recordNotify("Playback stopped: " .. tostring(err), 4)
			end
		end)
		MovementRecord.connection = connection
		if MovementRecord.controlsFallback and type(RunService.BindToRenderStep) == "function" then
			local bindName = "IY_CruzanRecordPlayback_" .. tostring(math.floor(os.clock() * 1000000))
			local bindPriority = 201
			pcall(function()
				bindPriority = Enum.RenderPriority.Input.Value + 1
			end)
			local bindOk = pcall(function()
				RunService:BindToRenderStep(bindName, bindPriority, function()
					if MovementRecord.mode == "approaching" then
						advanceNaturalStartApproach()
						return
					end
					if MovementRecord.mode ~= "playing" and MovementRecord.mode ~= "looping" then return end
					local elapsed = tonumber(MovementRecord.playbackCurrentElapsed) or 0
					local stepOk, stepError = applyPlaybackAt(elapsed)
					if not stepOk and stepError ~= "finished" then
						stopPlayback(true, false, "RenderStep playback failed: " .. tostring(stepError))
						recordNotify("Playback stopped: " .. tostring(stepError), 4)
					end
				end)
			end)
			if bindOk then MovementRecord.playbackRenderStepName = bindName end
		end
		if IY_RELOAD_INSTANCE_STATE and type(IY_RELOAD_INSTANCE_STATE.TrackConnection) == "function" then
			IY_RELOAD_INSTANCE_STATE.TrackConnection(connection)
		end
		if not silent then
			if MovementRecord.controlsFallback then
				recordNotify("Playback started in fallback mode; PlayerModule is unavailable, so movement may be less precise.", 5)
			else
				recordNotify(looping and "Loop playback started. Use Stop to end it." or "Playback started.", 4)
			end
		end
		updateRecordWindow()
		return true
	end

	local function clearSavedRecording(silent)
		if MovementRecord.mode == "recording" then cancelRecording() end
		if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true) end
		local paths = recordPaths(CURRENT_GAME_ID, CURRENT_PLACE_ID)
		local oldManifest = readManifest(paths.manifest)
		local oldPending = readManifest(paths.pending)
		local tombstone = {version = 3, deleted = true, gameId = CURRENT_GAME_ID, placeId = CURRENT_PLACE_ID, updatedAt = os.time()}
		local tombstoneRaw = safeJsonEncode(tombstone)
		if tombstoneRaw and ensureRecordFolder() then
			safeFileWrite(paths.manifest, tombstoneRaw)
			safeFileWrite(paths.pending, tombstoneRaw)
			deleteManifestChunks(oldManifest, paths.base)
			deleteManifestChunks(oldPending, paths.base)
			safeFileDelete(paths.pending)
		end
		MovementRecord.saved = nil
		syncSavedRecording()
		if not silent then recordNotify("Last recording for this game/place cleared.") end
		updateRecordWindow()
		return true
	end

	MovementRecord.Stop = function(silent)
		if MovementRecord.mode == "recording" then
			return finishRecording(silent == true, "stopped", true)
		elseif MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then
			return stopPlayback(silent == true, true)
		end
		return false
	end

	local function createRecordWindow()
		local old = IY_RELOAD_INSTANCE_STATE.recordWindow
		if old and old.Parent then pcall(function() old:Destroy() end) end
		local frame = Instance.new("Frame")
		frame.Name = "IY_CruzanRecordWindow"
		frame.Size = UDim2.new(0, 218, 0, 114)
		frame.Position = UDim2.new(0.5, -109, 0.66, -57)
		frame.BackgroundColor3 = currentShade1 or Color3.fromRGB(36, 36, 37)
		frame.BorderSizePixel = 0
		frame.Visible = false
		frame.Active = true
		frame.ZIndex = 80
		frame.Parent = PARENT
		table.insert(shade1, frame)
		IY_RELOAD_INSTANCE_STATE.recordWindow = frame
		table.insert(IY_RELOAD_INSTANCE_STATE.ownedInstances, frame)

		local titleBar = Instance.new("Frame")
		titleBar.Name = "Header"
		titleBar.Size = UDim2.new(1, 0, 0, 22)
		titleBar.BackgroundColor3 = currentShade2 or Color3.fromRGB(46, 46, 47)
		titleBar.BorderSizePixel = 0
		titleBar.Active = true
		titleBar.ZIndex = 81
		titleBar.Parent = frame
		table.insert(shade2, titleBar)

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(0, 7, 0, 0)
		title.Size = UDim2.new(1, -34, 1, 0)
		title.Font = Enum.Font.SourceSansBold
		title.Text = "Record"
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = currentText1 or Color3.new(1, 1, 1)
		title.ZIndex = 82
		title.Parent = titleBar
		table.insert(text1, title)

		local close = Instance.new("TextButton")
		close.Name = "Close"
		close.Size = UDim2.new(0, 21, 0, 20)
		close.Position = UDim2.new(1, -22, 0, 1)
		close.BackgroundColor3 = currentShade2 or Color3.fromRGB(46, 46, 47)
		close.BorderSizePixel = 0
		close.AutoButtonColor = false
		close.Text = "×"
		close.Font = Enum.Font.SourceSansBold
		close.TextSize = 16
		close.TextColor3 = currentText1 or Color3.new(1, 1, 1)
		close.ZIndex = 83
		close.Parent = titleBar
		table.insert(shade2, close)
		table.insert(text1, close)

		local status = Instance.new("TextLabel")
		status.Name = "Status"
		status.Position = UDim2.new(0, 6, 0, 23)
		status.Size = UDim2.new(1, -12, 0, 16)
		status.BackgroundTransparency = 1
		status.BorderSizePixel = 0
		status.Font = Enum.Font.SourceSans
		status.TextSize = 11
		status.Text = "Ready  •  00:00"
		status.TextXAlignment = Enum.TextXAlignment.Left
		status.TextColor3 = currentText1 or Color3.new(1, 1, 1)
		status.ZIndex = 82
		status.Parent = frame
		table.insert(text1, status)

		local function makeButton(name, caption, x, y, width)
			local button = Instance.new("TextButton")
			button.Name = name
			button.Position = UDim2.new(0, x, 0, y)
			button.Size = UDim2.new(0, width, 0, 21)
			button.BackgroundColor3 = currentShade2 or Color3.fromRGB(46, 46, 47)
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Font = Enum.Font.SourceSans
			button.TextSize = 12
			button.Text = caption
			button.TextColor3 = currentText1 or Color3.new(1, 1, 1)
			button.ZIndex = 82
			button.Parent = frame
			table.insert(shade2, button)
			table.insert(text1, button)
			return button
		end

		local recordButton = makeButton("RecordButton", "Record", 6, 42, 98)
		local playButton = makeButton("PlayButton", "Play", 114, 42, 98)
		local loopButton = makeButton("LoopButton", "Loop", 6, 66, 98)
		local stopButton = makeButton("StopButton", "Stop", 114, 66, 98)
		local saved = Instance.new("TextLabel")
		saved.Name = "SavedDuration"
		saved.Position = UDim2.new(0, 6, 0, 91)
		saved.Size = UDim2.new(1, -64, 0, 18)
		saved.BackgroundTransparency = 1
		saved.BorderSizePixel = 0
		saved.Font = Enum.Font.SourceSans
		saved.TextSize = 11
		saved.TextXAlignment = Enum.TextXAlignment.Left
		saved.TextColor3 = currentText1 or Color3.new(1, 1, 1)
		saved.Text = "Last: None"
		saved.ZIndex = 82
		saved.Parent = frame
		table.insert(text1, saved)
		local clear = makeButton("ClearButton", "Clear", 164, 91, 48)
		clear.Size = UDim2.new(0, 48, 0, 18)
		clear.TextSize = 11

		local dragState = nil
		local function onDragInputChanged(input)
			if not dragState then return end
			local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement and dragState.inputType == Enum.UserInputType.MouseButton1
			local isTouchMove = input == dragState.input and dragState.inputType == Enum.UserInputType.Touch
			if not isMouseMove and not isTouchMove then return end
			local dx = input.Position.X - dragState.start.X
			local dy = input.Position.Y - dragState.start.Y
			frame.Position = UDim2.new(dragState.position.X.Scale, dragState.position.X.Offset + dx, dragState.position.Y.Scale, dragState.position.Y.Offset + dy)
		end
		local function endDrag(input)
			if not dragState then return end
			if input == dragState.input or input.UserInputType == Enum.UserInputType.MouseButton1 then dragState = nil end
		end
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			dragState = {input = input, inputType = input.UserInputType, start = input.Position, position = frame.Position}
		end)
		local dragChanged = UserInputService.InputChanged:Connect(onDragInputChanged)
		local dragEnded = UserInputService.InputEnded:Connect(endDrag)
		IY_RELOAD_INSTANCE_STATE.TrackConnection(dragChanged)
		IY_RELOAD_INSTANCE_STATE.TrackConnection(dragEnded)

		close.MouseButton1Click:Connect(function() frame.Visible = false end)
		recordButton.MouseButton1Click:Connect(function()
			if MovementRecord.mode == "recording" then finishRecording(true, "stopped", true) else startRecording(true) end
			updateRecordWindow()
		end)
		playButton.MouseButton1Click:Connect(function()
			if MovementRecord.mode == "recording" then finishRecording(true, "stopped", true) end
			if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true) end
			startPlayback(false, true)
			updateRecordWindow()
		end)
		loopButton.MouseButton1Click:Connect(function()
			if MovementRecord.mode == "recording" then finishRecording(true, "stopped", true) end
			if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true) end
			startPlayback(true, true)
			updateRecordWindow()
		end)
		stopButton.MouseButton1Click:Connect(function()
			MovementRecord.Stop(true)
			updateRecordWindow()
		end)
		clear.MouseButton1Click:Connect(function() clearSavedRecording(true) end)
		local uiConnections = {}
		for _, object in ipairs({titleBar, close, recordButton, playButton, loopButton, stopButton, clear}) do
			-- Store UI click handlers are automatically destroyed with this frame; input drag connections are tracked above.
			if object and object.Destroying then end
		end
		MovementRecord.ui = {frame = frame, status = status, saved = saved, record = recordButton, play = playButton, loop = loopButton, stop = stopButton, clear = clear}
		return frame
	end

	createRecordWindow()
	local windowRefreshAccumulator = 0
	local windowHeartbeat = RunService.Heartbeat:Connect(function(dt)
		if not MovementRecord.ui or not MovementRecord.ui.frame or not MovementRecord.ui.frame.Parent then return end
		if MovementRecord.ui.frame.Visible then
			windowRefreshAccumulator = windowRefreshAccumulator + (tonumber(dt) or 0.016)
			if windowRefreshAccumulator >= 0.1 then
				windowRefreshAccumulator = 0
				updateRecordWindow()
			end
		end
	end)
	IY_RELOAD_INSTANCE_STATE.TrackConnection(windowHeartbeat)
	updateRecordWindow()

	MovementRecord.OpenWindow = function()
		if MovementRecord.ui and MovementRecord.ui.frame and MovementRecord.ui.frame.Parent then
			MovementRecord.ui.frame.Visible = true
			updateRecordWindow()
			return true
		end
		return false
	end
	IY_RELOAD_INSTANCE_STATE.movementRecorder = MovementRecord
	local diskSaved, recoveredPartial = loadPersistedRecording()
	if diskSaved then
		MovementRecord.saved = diskSaved
	else
		refreshSavedRecording()
	end
	syncSavedRecording()
	if recoveredPartial and MovementRecord.saved then
		recordNotify("Recovered the last saved checkpoint for this place after an interrupted recording.", 5)
	end

	addcmd('record', {}, function(args, speaker)
		local action = tostring(args[1] or ""):lower()
		if action == "" or action == "window" or action == "open" then
			MovementRecord.OpenWindow()
			return
		end
		MovementRecord.OpenWindow()
		if action == "start" then
			startRecording(false)
		elseif action == "toggle" then
			if MovementRecord.mode == "recording" then finishRecording(false, "stopped", true) else startRecording(false) end
		elseif action == "play" then
			if MovementRecord.mode == "recording" then finishRecording(true, "stopped", true) end
			if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true) end
			startPlayback(false, false)
		elseif action == "loop" then
			if MovementRecord.mode == "recording" then finishRecording(true, "stopped", true) end
			if MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then stopPlayback(true, true) end
			startPlayback(true, false)
		elseif action == "stop" then
			if MovementRecord.mode == "recording" then
				finishRecording(false, "stopped", true)
			elseif MovementRecord.mode == "playing" or MovementRecord.mode == "looping" or MovementRecord.mode == "approaching" then
				stopPlayback(false, true)
			else
				recordNotify("Nothing is recording or playing.")
			end
		elseif action == "clear" then
			clearSavedRecording(false)
		else
			recordNotify("Usage: record | record start | record play | record loop | record stop | record clear (60 Hz; saved per game/place when file APIs are available)", 5)
		end
		updateRecordWindow()
	end)
end
end)
if not __iyRecordInitOk then
    local recordState = IY_RELOAD_INSTANCE_STATE
    for index = #(recordState.connections or {}), __iyRecordConnStart + 1, -1 do
        local connection = recordState.connections[index]
        pcall(function() if connection and type(connection.Disconnect) == "function" then connection:Disconnect() end end)
        table.remove(recordState.connections, index)
    end
    for index = #(recordState.ownedInstances or {}), __iyRecordInstanceStart + 1, -1 do
        local object = recordState.ownedInstances[index]
        pcall(function() if object and object.Parent then object:Destroy() end end)
        table.remove(recordState.ownedInstances, index)
    end
    pcall(function() if recordState.recordWindow then recordState.recordWindow:Destroy() end end)
    recordState.recordWindow = nil
    recordState.movementRecorder = nil
    pcall(function() warn("[IY Record] Initialization failed: " .. tostring(__iyRecordInitError)) end)
    pcall(function() notify("Record Unavailable", "Recorder initialization failed. See console for details.", 5) end)
end

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	return COREGUI:TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	return GuiService:ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(Players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
	if saveinstance then
		notify("Loading", "Downloading game. This will take a while")
		saveinstance()
		notify("Game Saved", "Saved place to the workspace folder within your exploit folder.")
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing saveinstance)")
	end
end)

addcmd("clearerror", {"clearerrors"}, function(args, speaker)
    GuiService:ClearError()
end)

addcmd("antigameplaypaused", {}, function(args, speaker)
    pcall(function() networkPaused:Disconnect() end)
    networkPaused = COREGUI.RobloxGui.ChildAdded:Connect(function(obj)
        if obj.Name == "CoreScripts/NetworkPause" then
            obj:Destroy()
        end
    end)
    COREGUI.RobloxGui["CoreScripts/NetworkPause"]:Destroy()
end)

addcmd("unantigameplaypaused", {}, function(args, speaker)
    networkPaused:Disconnect()
end)

addcmd('clientantikick',{'antikick'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local LocalPlayer = Players.LocalPlayer
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    	local method = getnamecallmethod and getnamecallmethod() or ""
    	if select(1, ...) == LocalPlayer and method == "Kick" or method == "kick" then
        	return nil
    	end
    	return oldNamecall(...)
	end))
	hookfunction(LocalPlayer.Kick, newcclosure(function(self, _)
    	if self ~= lp then
        	error("Expected ':' not '.' calling member function Kick", 2)
    	end
    	return nil
	end))

	notify('Client Antikick','Client anti kick is now active (only effective on localscript kick)')
end)

allow_rj = true
addcmd('clientantiteleport',{'antiteleport'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end

	local oldTp; oldTp = hookfunction(TeleportService.Teleport, newcclosure(function(self, placeId, player, _teleportData, customLoadingScreen)
		if checkcaller() or (allow_rj and placeId == game.PlaceId) then
			return oldTp(self, placeId, player, _teleportData, customLoadingScreen)
		end
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function Teleport", 2)
		end
		if placeId == nil then
			error("Argument 1 missing or nil", 2)
		end
		if typeof(placeId) ~= "number" and placeId ~= true then
			error(`Unable to cast {typeof(placeId)} to int64`, 2)
		elseif placeId == true then
			-- somehow raise raiseTeleportInitFailedEvent
			return
		end
		if typeof(customLoadingScreen) ~= "Instance" and customLoadingScreen ~= nil then
			error("Unable to cast value to Object", 2)
		end
		return nil
	end))
	hookfunction(TeleportService.TeleportAsync, newcclosure(function(self, placeId, players, teleportOptions)
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function TeleportAsync", 2)
		end
		if players == nil then
			error("Argument 2 missing or nil", 2)
		end
		if typeof(players) ~= "table" then
			error("Unable to cast value to Objects", 2)
		end
		error("TeleportUnknown must be called from a Server", 2)
	end))
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		local nmc = getnamecallmethod()
		if select(1, ...) == TeleportService and nmc == "teleport" or nmc == "Teleport" or nmc == "TeleportToPlaceInstance" or nmc == "TeleportAsync" then
			if checkcaller() or (allow_rj and select(2, ...) == game.PlaceId) then
				return oldNamecall(...)
			end
			return
		end
		return oldNamecall(...)
	end))

	notify('Client AntiTP','Client anti teleport is now active (only effective on localscript teleport)')
end)

addcmd('allowrejoin',{'allowrj'},function(args, speaker)
	allow_rj = not allow_rj
	notify("Client AntiTP", `Scripts now may{allow_rj and "" or " not"} make you rejoin the server`)
end)

addcmd("cancelteleport", {"canceltp"}, function(args, speaker)
	TeleportService:TeleportCancel()
end)

addcmd("volume",{ "vol"}, function(args, speaker)
	UserSettings():GetService("UserGameSettings").MasterVolume = args[1]/10
end)

addcmd("antilag", {"boostfps", "lowgraphics"}, function(args, speaker)
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	IY_RELOAD_INSTANCE_STATE.TrackConnection(workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end))
end)

addcmd("setfpscap", {"fpscap", "maxfps"}, function(args, speaker)
	if fpscaploop then
		task.cancel(fpscaploop)
		fpscaploop = nil
	end

	local fpsCap = 60
	local num = tonumber(args[1]) or 1e6
	if num == "none" then
		return
	elseif num > 0 then
		fpsCap = num
	else
		return notify("Invalid argument", "Please provide a number above 0 or 'none'.")
	end

	if setfpscap and type(setfpscap) == "function" then
		setfpscap(fpsCap)
	else
		fpscaploop = task.spawn(function()
			local timer = os.clock()
			while true do
				if os.clock() >= timer + 1 / fpsCap then
					timer = os.clock()
					task.wait()
				end
			end
		end)
	end
end)

addcmd('notify',{},function(args, speaker)
	notify(getstring(1, args))
end)

addcmd('lastcommand',{'lastcmd'},function(args, speaker)
	if cmdHistory[1]:sub(1,11) ~= 'lastcommand' and cmdHistory[1]:sub(1,7) ~= 'lastcmd' then
		execCmd(cmdHistory[1])
	end
end)

addcmd('esp',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('espteam',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v, true)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('noesp',{'unesp','unespteam'},function(args, speaker)
	ESPenabled = false
	for i,c in pairs(COREGUI:GetChildren()) do
		if string.sub(c.Name, -4) == '_ESP' then
			c:Destroy()
		end
	end
end)

addcmd("esptransparency", {}, function(args, speaker)
    espTransparency = tonumber(args[1]) or 0.3
    if ESPenabled then execCmd("esp") end
    if CHMSenabled then execCmd("chams") end
    updatesaves()
end)

local espParts = {}
local partEspTrigger = nil
function partAdded(part)
	if #espParts > 0 then
		if FindInTable(espParts,part.Name:lower()) then
			local a = Instance.new("BoxHandleAdornment")
			a.Name = part.Name:lower().."_PESP"
			a.Parent = part
			a.Adornee = part
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = part.Size
			a.Transparency = espTransparency
			a.Color = BrickColor.new("Lime green")
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

addcmd('partesp',{},function(args, speaker)
	local partEspName = getstring(1, args):lower()
	if not FindInTable(espParts,partEspName) then
		table.insert(espParts,partEspName)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partEspName then
				local a = Instance.new("BoxHandleAdornment")
				a.Name = partEspName.."_PESP"
				a.Parent = v
				a.Adornee = v
				a.AlwaysOnTop = true
				a.ZIndex = 0
				a.Size = v.Size
				a.Transparency = espTransparency
				a.Color = BrickColor.new("Lime green")
			end
		end
	end
	if partEspTrigger == nil then
		partEspTrigger = workspace.DescendantAdded:Connect(partAdded)
	end
end)

addcmd('unpartesp',{'nopartesp'},function(args, speaker)
	if args[1] then
		local partEspName = getstring(1, args):lower()
		if FindInTable(espParts,partEspName) then
			table.remove(espParts, GetInTable(espParts, partEspName))
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name == partEspName..'_PESP' then
				v:Destroy()
			end
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
		espParts = {}
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name:sub(-5) == '_PESP' then
				v:Destroy()
			end
		end
	end
end)

addcmd('chams',{},function(args, speaker)
	if not ESPenabled then
		CHMSenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				CHMS(v)
			end
		end
	else
		notify('Chams','Disable ESP (noesp) before using chams')
	end
end)

addcmd('nochams',{'unchams'},function(args, speaker)
	CHMSenabled = false
	for i,v in pairs(Players:GetPlayers()) do
		local chmsplr = v
		for i,c in pairs(COREGUI:GetChildren()) do
			if c.Name == chmsplr.Name..'_CHMS' then
				c:Destroy()
			end
		end
	end
end)

addcmd('locate',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

addcmd('nolocate',{'unlocate'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(COREGUI:GetChildren()) do
				if c.Name == Players[v].Name..'_LC' then
					c:Destroy()
				end
			end
		end
	else
		for i,c in pairs(COREGUI:GetChildren()) do
			if string.sub(c.Name, -3) == '_LC' then
				c:Destroy()
			end
		end
	end
end)

viewing = nil
addcmd('view',{'spectate'},function(args, speaker)
	StopFreecam()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		viewing = Players[v]
		workspace.CurrentCamera.CameraSubject = viewing.Character
		notify('Spectate','Viewing ' .. Players[v].Name)
		local function viewDiedFunc()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewDied = Players[v].CharacterAdded:Connect(viewDiedFunc)
		local function viewChangedFunc()
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
	end
end)

addcmd('viewpart',{'viewp'},function(args, speaker)
	StopFreecam()
	if args[1] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
				wait(0.1)
				workspace.CurrentCamera.CameraSubject = v
			end
		end
	end
end)

addcmd('unview',{'unspectate'},function(args, speaker)
	StopFreecam()
	if viewing ~= nil then
		viewing = nil
		notify('Spectate','View turned off')
	end
	if viewDied then
		viewDied:Disconnect()
		viewChanged:Disconnect()
	end
	workspace.CurrentCamera.CameraSubject = speaker.Character
end)


fcRunning = false
local Camera = workspace.CurrentCamera
IY_RELOAD_INSTANCE_STATE.TrackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end))

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard",Keypress,false,INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",MousePan,false,INPUT_PRIORITY,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
		end
	end
end

function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))

	local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

	cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		Camera.FieldOfView = 70

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

function StartFreecam(pos)
	if fcRunning then
		StopFreecam()
	end
	local cameraCFrame = Camera.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
	fcRunning = true
end

function StopFreecam()
	if not fcRunning then return end
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
	workspace.Camera.FieldOfView = 70
	fcRunning = false
end

addcmd('freecam',{'fc'},function(args, speaker)
	StartFreecam()
end)

addcmd('freecampos',{'fcpos','fcp','freecamposition','fcposition'},function(args, speaker)
	if not args[1] then return end
	local freecamPos = CFrame.new(args[1],args[2],args[3])
	StartFreecam(freecamPos)
end)

addcmd('freecamwaypoint',{'fcwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(x,y,z))
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(pWayPoints[i].COORD[1].Position))
			end
		end
	end
end)

addcmd('freecamgoto',{'fcgoto','freecamtp','fctp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		StartFreecam(getRoot(Players[v].Character).CFrame)
	end
end)

addcmd('unfreecam',{'nofreecam','unfc','nofc'},function(args, speaker)
	StopFreecam()
end)

addcmd('freecamspeed',{'fcspeed'},function(args, speaker)
	local FCspeed = args[1] or 1
	if isNumber(FCspeed) then
		NAV_KEYBOARD_SPEED = Vector3.new(FCspeed, FCspeed, FCspeed)
	end
end)

addcmd('notifyfreecamposition',{'notifyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		notify("Current Position", Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('copyfreecamposition',{'copyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		toClipboard(Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('gotocamera',{'gotocam','tocam'},function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

addcmd('tweengotocamera',{'tweengotocam','tgotocam','ttocam'},function(args, speaker)
	TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = workspace.Camera.CFrame}):Play()
end)

addcmd('fov',{},function(args, speaker)
	local fov = args[1] or 70
	if isNumber(fov) then
		workspace.CurrentCamera.FieldOfView = fov
	end
end)

local preMaxZoom = Players.LocalPlayer.CameraMaxZoomDistance
local preMinZoom = Players.LocalPlayer.CameraMinZoomDistance
addcmd('lookat',{},function(args, speaker)
	if speaker.CameraMaxZoomDistance ~= 0.5 then
		preMaxZoom = speaker.CameraMaxZoomDistance
		preMinZoom = speaker.CameraMinZoomDistance
	end
	speaker.CameraMaxZoomDistance = 0.5
	speaker.CameraMinZoomDistance = 0.5
	wait()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local target = Players[v].Character
		if target and target:FindFirstChild('Head') then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.CFrame.p)
			wait(0.1)
		end
	end
	speaker.CameraMaxZoomDistance = preMaxZoom
	speaker.CameraMinZoomDistance = preMinZoom
end)

addcmd('fixcam',{'restorecam'},function(args, speaker)
	StopFreecam()
	execCmd('unview')
	workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end)

addcmd("enableshiftlock", {"enablesl", "shiftlock"}, function(args, speaker)
	local function enableShiftlock() 
		speaker.DevEnableMouseLock = true 
	end
	IY_RELOAD_INSTANCE_STATE.TrackConnection(speaker:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(enableShiftlock))
	enableShiftlock()
	notify("Shiftlock", "Shift lock should now be available")
end)

addcmd('firstp',{},function(args, speaker)
	speaker.CameraMode = "LockFirstPerson"
end)

addcmd('thirdp',{},function(args, speaker)
	speaker.CameraMode = "Classic"
end)

addcmd('noclipcam', {'nccam'}, function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then
		return notify('Incompatible Exploit', 'Your exploit does not support this command (missing setconstant or getconstants or getgc)')
	end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == 'function' and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == .25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, .25)
				end
			end
		end
	end
end)

addcmd('maxzoom',{},function(args, speaker)
	speaker.CameraMaxZoomDistance = args[1]
end)

addcmd('minzoom',{},function(args, speaker)
	speaker.CameraMinZoomDistance = args[1]
end)

addcmd('camdistance',{},function(args, speaker)
	local camMax = speaker.CameraMaxZoomDistance
	local camMin = speaker.CameraMinZoomDistance
	if camMax < tonumber(args[1]) then
		camMax = args[1]
	end
	speaker.CameraMaxZoomDistance = args[1]
	speaker.CameraMinZoomDistance = args[1]
	wait()
	speaker.CameraMaxZoomDistance = camMax
	speaker.CameraMinZoomDistance = camMin
end)

addcmd('unlockws',{'unlockworkspace'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

addcmd('lockws',{'lockworkspace'},function(args, speaker) 
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

addcmd('delete',{'remove'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('deleteclass',{'removeclass','deleteclassname','removeclassname','dc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('chardelete',{'charremove','cd'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('chardeleteclass',{'charremoveclass','chardeleteclassname','charremoveclassname','cdc'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('deletevelocity',{'dv','removevelocity','removeforces'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("RocketPropulsion") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") or v:IsA("AngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LineForce") then
			v:Destroy()
		end
	end
end)

addcmd('deleteinvisparts',{'deleteinvisibleparts','dip'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}
addcmd('invisibleparts',{'invisparts'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			if not table.find(shownParts,v) then
				table.insert(shownParts,v)
			end
			v.Transparency = 0
		end
	end
end)

addcmd('uninvisibleparts',{'uninvisparts'},function(args, speaker)
	for i,v in pairs(shownParts) do
		v.Transparency = 1
	end
	shownParts = {}
end)

addcmd("btools", {}, function(args, speaker)
	for i = 1, 4 do
		local Tool = Instance.new("HopperBin")
		Tool.BinType = i
		Tool.Name = randomString()
		Tool.Parent = speaker:FindFirstChildWhichIsA("Backpack")
	end
end)

addcmd("f3x", {"fex"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)

addcmd("partpath", {"partname"}, function(args, speaker)
	selectPart()
end)

local antiAfkCon = nil
addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, c in getconnections(speaker.Idled) do
            pcall(function() c:Disable() end) -- supposed to "pause" it
            pcall(function() c:Disconnect() end) -- supposed to disconnect it
        end
    end

    pcall(function() antiAfkCon:Disconnect() end)
    antiAfkCon = speaker.Idled:Connect(function()
        local VirtualInputManager = Instance.new("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:Destroy()
    end)

    if not (args[1] and tostring(args[1]) == "nonotify") then notify("Anti Idle", "Anti idle is enabled") end
end)

addcmd("datalimit", {}, function(args, speaker)
	local kbps = tonumber(args[1])
	if kbps then
		Services.NetworkClient:SetOutgoingKBPSLimit(kbps)
	end
end)

addcmd("replicationlag", {"backtrack"}, function(args, speaker)
	if tonumber(args[1]) then
		settings():GetService("NetworkSettings").IncomingReplicationLag = args[1]
	end
end)

addcmd("noprompts", {"nopurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = false
end)

addcmd("showprompts", {"showpurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = true
end)

promptNewRig = function(speaker, rig)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		AvatarEditorService:PromptSaveAvatar(humanoid.HumanoidDescription, Enum.HumanoidRigType[rig])
		local result = AvatarEditorService.PromptSaveAvatarCompleted:Wait()
		if result == Enum.AvatarPromptResult.Success then
			execCmd("reset")
		end
	end
end

addcmd("promptr6", {}, function(args, speaker)
	promptNewRig(speaker, "R6")
end)

addcmd("promptr15", {}, function(args, speaker)
	promptNewRig(speaker, "R15")
end)

addcmd("wallwalk", {"walkonwalls"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

addcmd('age',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	notify('Account Age',table.concat(ages, ',\n'))
end)

addcmd('chatage',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	local chatString = table.concat(ages, ', ')
	chatMessage(chatString)
end)

addcmd('joindate',{'jd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	notify('Join Date (Month/Day/Year)',table.concat(dates, ',\n'))
end)

addcmd('chatjoindate',{'cjd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	local chatString = table.concat(dates, ', ')
	chatMessage(chatString)
end)

addcmd('copyname',{'copyuser'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
	end
end)

addcmd('userid',{'id'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		notify('User ID',id)
	end
end)

addcmd("copyplaceid", {"placeid"}, function(args, speaker)
	toClipboard(PlaceId)
end)

addcmd("copygameid", {"gameid"}, function(args, speaker)
	toClipboard(game.GameId)
end)

addcmd('copyid',{'copyuserid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
	end
end)

addcmd('creatorid',{'creator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		notify('Creator ID',game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Creator ID',OwnerID)
	end
end)

addcmd('copycreatorid',{'copycreator'},function(args, speaker)
	if