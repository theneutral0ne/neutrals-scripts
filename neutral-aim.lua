local RunService = game.GetService(game, "RunService")
local Players = game.GetService(game, "Players")
local WorkspaceService = game.GetService(game, "Workspace")
local UserInputService = game.GetService(game, "UserInputService")
local TweenService = game.GetService(game, "TweenService")
local VirtualInputManager = game.GetService(game, "VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = WorkspaceService.CurrentCamera
local MouseObject = LocalPlayer.GetMouse(LocalPlayer)

local FovCircle = Drawing.new("Circle")
FovCircle.Radius = 300
FovCircle.Thickness = 2
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 1
FovCircle.Visible = true
FovCircle.NumSides = 64

local TargetLine = Drawing.new("Line")
TargetLine.Thickness = 1
TargetLine.Transparency = 1
TargetLine.Color = Color3.fromRGB(255, 255, 255)
TargetLine.Visible = false

local TargetCubeEdgeColor3 = Color3.fromRGB(255, 220, 0)
local TargetCubeLineThicknessNumber = 2
local TargetCubeLines = {}

for LineIndex = 1, 4 do
	local Line = Drawing.new("Line")
	Line.Thickness = TargetCubeLineThicknessNumber
	Line.Transparency = 1
	Line.Color = TargetCubeEdgeColor3
	Line.Visible = false
	TargetCubeLines[LineIndex] = Line
end

CurrentTargetPartInstance = nil
CurrentTargetCharacterModel = nil
CurrentTargetPlayerObject = nil
CurrentTargetPointVector3 = nil
CurrentTargetCubeCFrame = nil
CurrentTargetCubeSize = nil

local AimbotSmoothingNumber = 0.2
local AimbotRequireRmbBoolean = true

local MinSmoothingNumber = 0.01
local MaxSmoothingNumber = 1.0

local MinFovRadiusNumber = 50
local MaxFovRadiusNumber = 600

local MaxDistanceNumber = 750

local HeadshotPriorityBoolean = false

local AutoFireEnabledBoolean = true
local AutoFireCooldownNumber = 0.1
local LastAutoFireTimeNumber = 0

local VisibleCheckEnabledBoolean = true
local VisibleCheckSubdivisionsNumber = 4

local ShowFovCircleBoolean = true
local ShowTargetLineBoolean = true

local UseHookMethodBoolean = true
local UseCameraMethodBoolean = true

local RetargetMinImprovementNumber = 0
local TargetSearchIntervalNumber = 0.1
local LastTargetSearchTimeNumber = 0
local VisibilityRaycastParams = RaycastParams.new()
VisibilityRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local LastRaycastCharacterModel = nil

local CustomTeamCheckGameIdNumber = 7264587281
local UseCustomTeamCheckBoolean = (game.GameId == CustomTeamCheckGameIdNumber)

local UseEKeyForLockOnBoolean = false

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "AimbotSettingsGui"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
MenuGui.DisplayOrder = 9999
MenuGui.Parent = gethui()

local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MainFrame"
MenuFrame.Size = UDim2.new(0, 230, 0, 400)
MenuFrame.Position = UDim2.new(0, 20, 0, 200)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.ZIndex = 100
MenuFrame.Parent = MenuGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -10, 0, 24)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Aimbot Settings"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 101
TitleLabel.Parent = MenuFrame

local function CreateSectionHeader(SectionTitleString, YOffsetNumber)
	local HeaderFrame = Instance.new("Frame")
	HeaderFrame.Name = SectionTitleString .. "HeaderFrame"
	HeaderFrame.Size = UDim2.new(1, -20, 0, 20)
	HeaderFrame.Position = UDim2.new(0, 10, 0, YOffsetNumber)
	HeaderFrame.BackgroundTransparency = 1
	HeaderFrame.ZIndex = 101
	HeaderFrame.Parent = MenuFrame

	local HeaderLabel = Instance.new("TextLabel")
	HeaderLabel.Name = SectionTitleString .. "HeaderLabel"
	HeaderLabel.Size = UDim2.new(0, 120, 1, 0)
	HeaderLabel.BackgroundTransparency = 1
	HeaderLabel.Text = SectionTitleString
	HeaderLabel.Font = Enum.Font.SourceSansSemibold
	HeaderLabel.TextSize = 14
	HeaderLabel.TextColor3 = Color3.fromRGB(0, 200, 200)
	HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
	HeaderLabel.ZIndex = 102
	HeaderLabel.Parent = HeaderFrame

	local Divider = Instance.new("Frame")
	Divider.Name = SectionTitleString .. "Divider"
	Divider.Size = UDim2.new(1, -125, 0, 1)
	Divider.Position = UDim2.new(0, 125, 0.5, 0)
	Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Divider.BorderSizePixel = 0
	Divider.ZIndex = 101
	Divider.Parent = HeaderFrame
end

CreateSectionHeader("Aim Settings", 30)

local SmoothingValueLabel = Instance.new("TextLabel")
SmoothingValueLabel.Name = "SmoothingValueLabel"
SmoothingValueLabel.Size = UDim2.new(1, -10, 0, 20)
SmoothingValueLabel.Position = UDim2.new(0, 5, 0, 52)
SmoothingValueLabel.BackgroundTransparency = 1
SmoothingValueLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothingValueLabel.Font = Enum.Font.SourceSans
SmoothingValueLabel.TextSize = 16
SmoothingValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SmoothingValueLabel.Text = "Smoothing: " .. string.format("%.2f", AimbotSmoothingNumber)
SmoothingValueLabel.ZIndex = 101
SmoothingValueLabel.Parent = MenuFrame

local SmoothSliderBackFrame = Instance.new("Frame")
SmoothSliderBackFrame.Name = "SmoothSliderBackFrame"
SmoothSliderBackFrame.Size = UDim2.new(1, -20, 0, 8)
SmoothSliderBackFrame.Position = UDim2.new(0, 10, 0, 76)
SmoothSliderBackFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SmoothSliderBackFrame.BorderSizePixel = 0
SmoothSliderBackFrame.ZIndex = 101
SmoothSliderBackFrame.Parent = MenuFrame

local SmoothSliderFillFrame = Instance.new("Frame")
SmoothSliderFillFrame.Name = "SmoothSliderFillFrame"
SmoothSliderFillFrame.Size = UDim2.new(0, 0, 1, 0)
SmoothSliderFillFrame.Position = UDim2.new(0, 0, 0, 0)
SmoothSliderFillFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SmoothSliderFillFrame.BorderSizePixel = 0
SmoothSliderFillFrame.ZIndex = 102
SmoothSliderFillFrame.Parent = SmoothSliderBackFrame

local SmoothSliderKnobFrame = Instance.new("Frame")
SmoothSliderKnobFrame.Name = "SmoothSliderKnobFrame"
SmoothSliderKnobFrame.Size = UDim2.new(0, 10, 0, 14)
SmoothSliderKnobFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SmoothSliderKnobFrame.BorderSizePixel = 0
SmoothSliderKnobFrame.ZIndex = 103
SmoothSliderKnobFrame.Parent = SmoothSliderBackFrame

local FovValueLabel = Instance.new("TextLabel")
FovValueLabel.Name = "FovValueLabel"
FovValueLabel.Size = UDim2.new(1, -10, 0, 20)
FovValueLabel.Position = UDim2.new(0, 5, 0, 102)
FovValueLabel.BackgroundTransparency = 1
FovValueLabel.TextXAlignment = Enum.TextXAlignment.Left
FovValueLabel.Font = Enum.Font.SourceSans
FovValueLabel.TextSize = 16
FovValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FovValueLabel.Text = "FOV Radius: " .. tostring(FovCircle.Radius)
FovValueLabel.ZIndex = 101
FovValueLabel.Parent = MenuFrame

local FovSliderBackFrame = Instance.new("Frame")
FovSliderBackFrame.Name = "FovSliderBackFrame"
FovSliderBackFrame.Size = UDim2.new(1, -20, 0, 8)
FovSliderBackFrame.Position = UDim2.new(0, 10, 0, 126)
FovSliderBackFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FovSliderBackFrame.BorderSizePixel = 0
FovSliderBackFrame.ZIndex = 101
FovSliderBackFrame.Parent = MenuFrame

local FovSliderFillFrame = Instance.new("Frame")
FovSliderFillFrame.Name = "FovSliderFillFrame"
FovSliderFillFrame.Size = UDim2.new(0, 0, 1, 0)
FovSliderFillFrame.Position = UDim2.new(0, 0, 0, 0)
FovSliderFillFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
FovSliderFillFrame.BorderSizePixel = 0
FovSliderFillFrame.ZIndex = 102
FovSliderFillFrame.Parent = FovSliderBackFrame

local FovSliderKnobFrame = Instance.new("Frame")
FovSliderKnobFrame.Name = "FovSliderKnobFrame"
FovSliderKnobFrame.Size = UDim2.new(0, 10, 0, 14)
FovSliderKnobFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovSliderKnobFrame.BorderSizePixel = 0
FovSliderKnobFrame.ZIndex = 103
FovSliderKnobFrame.Parent = FovSliderBackFrame

local HeadshotToggleButton = Instance.new("TextButton")
HeadshotToggleButton.Name = "HeadshotToggleButton"
HeadshotToggleButton.Size = UDim2.new(1, -20, 0, 20)
HeadshotToggleButton.Position = UDim2.new(0, 10, 0, 172)
HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
HeadshotToggleButton.BorderSizePixel = 0
HeadshotToggleButton.Text = "Headshot Priority: OFF"
HeadshotToggleButton.Font = Enum.Font.SourceSans
HeadshotToggleButton.TextSize = 16
HeadshotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadshotToggleButton.ZIndex = 101
HeadshotToggleButton.Parent = MenuFrame

local AutoFireToggleButton = Instance.new("TextButton")
AutoFireToggleButton.Name = "AutoFireToggleButton"
AutoFireToggleButton.Size = UDim2.new(1, -20, 0, 20)
AutoFireToggleButton.Position = UDim2.new(0, 10, 0, 196)
AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
AutoFireToggleButton.BorderSizePixel = 0
AutoFireToggleButton.Text = "Auto Fire: ON"
AutoFireToggleButton.Font = Enum.Font.SourceSans
AutoFireToggleButton.TextSize = 16
AutoFireToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFireToggleButton.ZIndex = 101
AutoFireToggleButton.Parent = MenuFrame

local VisibleCheckToggleButton = Instance.new("TextButton")
VisibleCheckToggleButton.Name = "VisibleCheckToggleButton"
VisibleCheckToggleButton.Size = UDim2.new(1, -20, 0, 20)
VisibleCheckToggleButton.Position = UDim2.new(0, 10, 0, 252)
VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
VisibleCheckToggleButton.BorderSizePixel = 0
VisibleCheckToggleButton.Text = "Visible Check: ON"
VisibleCheckToggleButton.Font = Enum.Font.SourceSans
VisibleCheckToggleButton.TextSize = 16
VisibleCheckToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VisibleCheckToggleButton.ZIndex = 101
VisibleCheckToggleButton.Parent = MenuFrame

local FovToggleButton = Instance.new("TextButton")
FovToggleButton.Name = "FovToggleButton"
FovToggleButton.Size = UDim2.new(1, -20, 0, 20)
FovToggleButton.Position = UDim2.new(0, 10, 0, 276)
FovToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FovToggleButton.BorderSizePixel = 0
FovToggleButton.Text = "FOV Circle: ON"
FovToggleButton.Font = Enum.Font.SourceSans
FovToggleButton.TextSize = 16
FovToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FovToggleButton.ZIndex = 101
FovToggleButton.Parent = MenuFrame

local TargetLineToggleButton = Instance.new("TextButton")
TargetLineToggleButton.Name = "TargetLineToggleButton"
TargetLineToggleButton.Size = UDim2.new(1, -20, 0, 20)
TargetLineToggleButton.Position = UDim2.new(0, 10, 0, 300)
TargetLineToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
TargetLineToggleButton.BorderSizePixel = 0
TargetLineToggleButton.Text = "Target Line: ON"
TargetLineToggleButton.Font = Enum.Font.SourceSans
TargetLineToggleButton.TextSize = 16
TargetLineToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetLineToggleButton.ZIndex = 101
TargetLineToggleButton.Parent = MenuFrame

local LockKeyToggleButton = Instance.new("TextButton")
LockKeyToggleButton.Name = "LockKeyToggleButton"
LockKeyToggleButton.Size = UDim2.new(1, -20, 0, 20)
LockKeyToggleButton.Position = UDim2.new(0, 10, 0, 352)
LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
LockKeyToggleButton.BorderSizePixel = 0
LockKeyToggleButton.Text = "Lock Key: RMB"
LockKeyToggleButton.Font = Enum.Font.SourceSans
LockKeyToggleButton.TextSize = 16
LockKeyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LockKeyToggleButton.ZIndex = 101
LockKeyToggleButton.Parent = MenuFrame

local HookMethodToggleButton = Instance.new("TextButton")
HookMethodToggleButton.Name = "HookMethodToggleButton"
HookMethodToggleButton.Size = UDim2.new(1, -20, 0, 20)
HookMethodToggleButton.Position = UDim2.new(0, 10, 0, 376)
HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
HookMethodToggleButton.BorderSizePixel = 0
HookMethodToggleButton.Text = "Method: Hook"
HookMethodToggleButton.Font = Enum.Font.SourceSans
HookMethodToggleButton.TextSize = 16
HookMethodToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HookMethodToggleButton.ZIndex = 101
HookMethodToggleButton.Parent = MenuFrame

CreateSectionHeader("Targeting", 150)
CreateSectionHeader("Visibility", 230)
CreateSectionHeader("Behavior", 330)

local function UpdateHeadshotButtonAppearance()
	if HeadshotPriorityBoolean then
		HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
		HeadshotToggleButton.Text = "Headshot Priority: ON"
	else
		HeadshotToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
		HeadshotToggleButton.Text = "Headshot Priority: OFF"
	end
end

local function UpdateAutoFireButtonAppearance()
	if AutoFireEnabledBoolean then
		AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
		AutoFireToggleButton.Text = "Auto Fire: ON"
	else
		AutoFireToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		AutoFireToggleButton.Text = "Auto Fire: OFF"
	end
end

local function UpdateVisibleCheckButtonAppearance()
	if VisibleCheckEnabledBoolean then
		VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		VisibleCheckToggleButton.Text = "Visible Check: ON"
	else
		VisibleCheckToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		VisibleCheckToggleButton.Text = "Visible Check: OFF"
	end
end

local function UpdateFovToggleButtonAppearance()
	if ShowFovCircleBoolean then
		FovToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		FovToggleButton.Text = "FOV Circle: ON"
	else
		FovToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		FovToggleButton.Text = "FOV Circle: OFF"
	end
end

local function UpdateTargetLineToggleButtonAppearance()
	if ShowTargetLineBoolean then
		TargetLineToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
		TargetLineToggleButton.Text = "Target Line: ON"
	else
		TargetLineToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		TargetLineToggleButton.Text = "Target Line: OFF"
	end
end

local function UpdateHookMethodButtonAppearance()
	if UseHookMethodBoolean and UseCameraMethodBoolean then
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
		HookMethodToggleButton.Text = "Method: Both"
	elseif UseHookMethodBoolean then
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(150, 70, 200)
		HookMethodToggleButton.Text = "Method: Hook"
	else
		HookMethodToggleButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
		HookMethodToggleButton.Text = "Method: Camera"
	end
end

local function UpdateLockKeyButtonAppearance()
	if UseEKeyForLockOnBoolean then
		LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(0, 130, 130)
		LockKeyToggleButton.Text = "Lock Key: E"
	else
		LockKeyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
		LockKeyToggleButton.Text = "Lock Key: RMB"
	end
end

HeadshotToggleButton.MouseButton1Click.Connect(HeadshotToggleButton.MouseButton1Click, function()
	HeadshotPriorityBoolean = not HeadshotPriorityBoolean
	UpdateHeadshotButtonAppearance()
end)

AutoFireToggleButton.MouseButton1Click.Connect(AutoFireToggleButton.MouseButton1Click, function()
	AutoFireEnabledBoolean = not AutoFireEnabledBoolean
	UpdateAutoFireButtonAppearance()
end)

VisibleCheckToggleButton.MouseButton1Click.Connect(VisibleCheckToggleButton.MouseButton1Click, function()
	VisibleCheckEnabledBoolean = not VisibleCheckEnabledBoolean
	UpdateVisibleCheckButtonAppearance()
end)

FovToggleButton.MouseButton1Click.Connect(FovToggleButton.MouseButton1Click, function()
	ShowFovCircleBoolean = not ShowFovCircleBoolean
	UpdateFovToggleButtonAppearance()
end)

TargetLineToggleButton.MouseButton1Click.Connect(TargetLineToggleButton.MouseButton1Click, function()
	ShowTargetLineBoolean = not ShowTargetLineBoolean
	UpdateTargetLineToggleButtonAppearance()
	TargetLine.Visible = false
	SetTargetCubeVisible(false)
end)

LockKeyToggleButton.MouseButton1Click.Connect(LockKeyToggleButton.MouseButton1Click, function()
	UseEKeyForLockOnBoolean = not UseEKeyForLockOnBoolean
	UpdateLockKeyButtonAppearance()
end)

HookMethodToggleButton.MouseButton1Click.Connect(HookMethodToggleButton.MouseButton1Click, function()
	if UseHookMethodBoolean and not UseCameraMethodBoolean then
		UseHookMethodBoolean = true
		UseCameraMethodBoolean = true
	elseif UseHookMethodBoolean and UseCameraMethodBoolean then
		UseHookMethodBoolean = false
		UseCameraMethodBoolean = true
	else
		UseHookMethodBoolean = true
		UseCameraMethodBoolean = false
	end
	UpdateHookMethodButtonAppearance()
end)

UpdateHeadshotButtonAppearance()
UpdateAutoFireButtonAppearance()
UpdateVisibleCheckButtonAppearance()
UpdateFovToggleButtonAppearance()
UpdateTargetLineToggleButtonAppearance()
UpdateLockKeyButtonAppearance()
UpdateHookMethodButtonAppearance()

local UiService = game.GetService(game, "UserInputService")

local DraggingUiBoolean = false
local DragStartInputPosition
local StartMenuPosition

TitleLabel.InputBegan.Connect(TitleLabel.InputBegan, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		DraggingUiBoolean = true
		DragStartInputPosition = InputObject.Position
		StartMenuPosition = MenuFrame.Position
	end
end)

UiService.InputChanged.Connect(UiService.InputChanged, function(InputObject)
	if DraggingUiBoolean and InputObject.UserInputType == Enum.UserInputType.MouseMovement then
		local DeltaVector2 = InputObject.Position - DragStartInputPosition
		MenuFrame.Position = UDim2.new(
			StartMenuPosition.X.Scale,
			StartMenuPosition.X.Offset + DeltaVector2.X,
			StartMenuPosition.Y.Scale,
			StartMenuPosition.Y.Offset + DeltaVector2.Y
		)
	end
end)

UiService.InputEnded.Connect(UiService.InputEnded, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		DraggingUiBoolean = false
	end
end)

local UiDragEnabledBoolean = true
local SmoothSliderDraggingBoolean = false
local FovSliderDraggingBoolean = false

local function SetSmoothingFromRatio(RatioNumber)
	RatioNumber = math.clamp(RatioNumber, 0, 1)
	AimbotSmoothingNumber = MinSmoothingNumber + (MaxSmoothingNumber - MinSmoothingNumber) * RatioNumber
	SmoothingValueLabel.Text = "Smoothing: " .. string.format("%.2f", AimbotSmoothingNumber)
	local BackWidthNumber = SmoothSliderBackFrame.AbsoluteSize.X
	local KnobWidthNumber = SmoothSliderKnobFrame.AbsoluteSize.X
	SmoothSliderFillFrame.Size = UDim2.new(RatioNumber, 0, 1, 0)
	SmoothSliderKnobFrame.Position = UDim2.new(RatioNumber, -KnobWidthNumber / 2, 0.5, -SmoothSliderKnobFrame.AbsoluteSize.Y / 2)
end

local function SetFovFromRatio(RatioNumber)
	RatioNumber = math.clamp(RatioNumber, 0, 1)
	local NewRadiusNumber = MinFovRadiusNumber + (MaxFovRadiusNumber - MinFovRadiusNumber) * RatioNumber
	FovCircle.Radius = NewRadiusNumber
	FovValueLabel.Text = "FOV Radius: " .. tostring(math.floor(NewRadiusNumber))
	local BackWidthNumber = FovSliderBackFrame.AbsoluteSize.X
	local KnobWidthNumber = FovSliderKnobFrame.AbsoluteSize.X
	FovSliderFillFrame.Size = UDim2.new(RatioNumber, 0, 1, 0)
	FovSliderKnobFrame.Position = UDim2.new(RatioNumber, -KnobWidthNumber / 2, 0.5, -FovSliderKnobFrame.AbsoluteSize.Y / 2)
end

local function UpdateSmoothSliderFromMouse()
	local MouseLocationVector2 = UiService.GetMouseLocation(UiService)
	local BackPositionVector2 = SmoothSliderBackFrame.AbsolutePosition
	local BackSizeVector2 = SmoothSliderBackFrame.AbsoluteSize
	local RelativeXNumber = math.clamp(MouseLocationVector2.X - BackPositionVector2.X, 0, BackSizeVector2.X)
	local RatioNumber = 0
	if BackSizeVector2.X > 0 then
		RatioNumber = RelativeXNumber / BackSizeVector2.X
	end
	SetSmoothingFromRatio(RatioNumber)
end

local function UpdateFovSliderFromMouse()
	local MouseLocationVector2 = UiService.GetMouseLocation(UiService)
	local BackPositionVector2 = FovSliderBackFrame.AbsolutePosition
	local BackSizeVector2 = FovSliderBackFrame.AbsoluteSize
	local RelativeXNumber = math.clamp(MouseLocationVector2.X - BackPositionVector2.X, 0, BackSizeVector2.X)
	local RatioNumber = 0
	if BackSizeVector2.X > 0 then
		RatioNumber = RelativeXNumber / BackSizeVector2.X
	end
	SetFovFromRatio(RatioNumber)
end

SmoothSliderBackFrame.InputBegan.Connect(SmoothSliderBackFrame.InputBegan, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiDragEnabledBoolean = false
		SmoothSliderDraggingBoolean = true
		UpdateSmoothSliderFromMouse()
	end
end)

SmoothSliderKnobFrame.InputBegan.Connect(SmoothSliderKnobFrame.InputBegan, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiDragEnabledBoolean = false
		SmoothSliderDraggingBoolean = true
		UpdateSmoothSliderFromMouse()
	end
end)

FovSliderBackFrame.InputBegan.Connect(FovSliderBackFrame.InputBegan, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiDragEnabledBoolean = false
		FovSliderDraggingBoolean = true
		UpdateFovSliderFromMouse()
	end
end)

FovSliderKnobFrame.InputBegan.Connect(FovSliderKnobFrame.InputBegan, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		UiDragEnabledBoolean = false
		FovSliderDraggingBoolean = true
		UpdateFovSliderFromMouse()
	end
end)

UiService.InputChanged.Connect(UiService.InputChanged, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseMovement then
		if SmoothSliderDraggingBoolean then
			UpdateSmoothSliderFromMouse()
		end
		if FovSliderDraggingBoolean then
			UpdateFovSliderFromMouse()
		end
	end
end)

UiService.InputEnded.Connect(UiService.InputEnded, function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		if SmoothSliderDraggingBoolean or FovSliderDraggingBoolean then
			SmoothSliderDraggingBoolean = false
			FovSliderDraggingBoolean = false
			UiDragEnabledBoolean = true
		end
	end
end)

task.defer(function()
	local DefaultSmoothRatioNumber = (AimbotSmoothingNumber - MinSmoothingNumber) / (MaxSmoothingNumber - MinSmoothingNumber)
	DefaultSmoothRatioNumber = math.clamp(DefaultSmoothRatioNumber, 0, 1)
	SetSmoothingFromRatio(DefaultSmoothRatioNumber)
	local DefaultFovRatioNumber = (FovCircle.Radius - MinFovRadiusNumber) / (MaxFovRadiusNumber - MinFovRadiusNumber)
	DefaultFovRatioNumber = math.clamp(DefaultFovRatioNumber, 0, 1)
	SetFovFromRatio(DefaultFovRatioNumber)
end)

local MenuIsOpenBoolean = true
local MenuOpenPosition = MenuFrame.Position
local MenuClosedPosition = UDim2.new(MenuOpenPosition.X.Scale, MenuOpenPosition.X.Offset, MenuOpenPosition.Y.Scale, MenuOpenPosition.Y.Offset - 150)
local MenuTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

MenuFrame.Position = MenuOpenPosition
MenuFrame.Visible = true

local function SetMenuOpen(OpenBoolean)
	if MenuIsOpenBoolean == OpenBoolean then
		return
	end
	MenuIsOpenBoolean = OpenBoolean
	if OpenBoolean then
		MenuFrame.Visible = true
		MenuFrame.Position = MenuClosedPosition
		local OpenTweenObject = TweenService.Create(TweenService, MenuFrame, MenuTweenInfo, { Position = MenuOpenPosition })
		OpenTweenObject:Play()
	else
		local CloseTweenObject = TweenService.Create(TweenService, MenuFrame, MenuTweenInfo, { Position = MenuClosedPosition })
		CloseTweenObject.Completed.Connect(CloseTweenObject.Completed, function()
			if not MenuIsOpenBoolean then
				MenuFrame.Visible = false
			end
		end)
		CloseTweenObject:Play()
	end
end

UiService.InputBegan.Connect(UiService.InputBegan, function(InputObject, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end
	if InputObject.KeyCode == Enum.KeyCode.RightShift then
		SetMenuOpen(not MenuIsOpenBoolean)
	end
end)

local function IsPointInCircle(PointVector2, CircleCenterVector2, CircleRadiusNumber)
	return (PointVector2 - CircleCenterVector2).Magnitude <= CircleRadiusNumber
end

local function GetCubeSize(TargetPart)
	if VisibleCheckEnabledBoolean then
		local SegmentCount = math.max(VisibleCheckSubdivisionsNumber, 1)
		return Vector3.new(
			TargetPart.Size.X / SegmentCount,
			TargetPart.Size.Y / SegmentCount,
			TargetPart.Size.Z / SegmentCount
		)
	end
	return TargetPart.Size
end

local function GetCubeCorners(CubeCFrame, CubeSize)
	local Half = CubeSize * 0.5
	local LocalCorners = {
		Vector3.new(-Half.X, -Half.Y, -Half.Z),
		Vector3.new(Half.X, -Half.Y, -Half.Z),
		Vector3.new(Half.X, Half.Y, -Half.Z),
		Vector3.new(-Half.X, Half.Y, -Half.Z),
		Vector3.new(-Half.X, -Half.Y, Half.Z),
		Vector3.new(Half.X, -Half.Y, Half.Z),
		Vector3.new(Half.X, Half.Y, Half.Z),
		Vector3.new(-Half.X, Half.Y, Half.Z),
	}
	local WorldCorners = {}
	for Index, LocalCorner in ipairs(LocalCorners) do
		WorldCorners[Index] = CubeCFrame:PointToWorldSpace(LocalCorner)
	end
	return WorldCorners
end

local function SetTargetCubeVisible(IsVisible)
	for _, Line in ipairs(TargetCubeLines) do
		Line.Visible = IsVisible
	end
end

local function GetPlateCorners(CubeCFrame, CubeSize, SurfacePointVector3)
	local Center = CubeCFrame.Position
	local NormalVector3 = SurfacePointVector3 and (SurfacePointVector3 - Center) or Vector3.zero
	if NormalVector3.Magnitude == 0 then
		NormalVector3 = CubeCFrame.LookVector
	else
		NormalVector3 = NormalVector3.Unit
	end

	local Axes = {
		{ axis = CubeCFrame.RightVector, size = CubeSize.X },
		{ axis = CubeCFrame.UpVector, size = CubeSize.Y },
		{ axis = CubeCFrame.LookVector, size = CubeSize.Z },
	}

	local ThicknessIndex = 1
	local BestDot = math.abs(NormalVector3:Dot(Axes[1].axis))
	for Index = 2, 3 do
		local AxisDot = math.abs(NormalVector3:Dot(Axes[Index].axis))
		if AxisDot > BestDot then
			BestDot = AxisDot
			ThicknessIndex = Index
		end
	end

	local ThicknessAxis = Axes[ThicknessIndex]
	local PlateAxes = {}
	for Index = 1, 3 do
		if Index ~= ThicknessIndex then
			table.insert(PlateAxes, Axes[Index])
		end
	end

	local ThicknessDot = NormalVector3:Dot(ThicknessAxis.axis)
	local ThicknessSign = ThicknessDot >= 0 and 1 or -1
	local PlateCenter = Center + ThicknessAxis.axis * (ThicknessAxis.size * 0.5 * ThicknessSign)
	local HalfAxisA = PlateAxes[1].axis * (PlateAxes[1].size * 0.5)
	local HalfAxisB = PlateAxes[2].axis * (PlateAxes[2].size * 0.5)

	return {
		PlateCenter - HalfAxisA - HalfAxisB,
		PlateCenter + HalfAxisA - HalfAxisB,
		PlateCenter + HalfAxisA + HalfAxisB,
		PlateCenter - HalfAxisA + HalfAxisB,
	}
end

local function UpdateTargetCube(CubeCFrame, CubeSize, SurfacePointVector3)
	local WorldCorners = GetPlateCorners(CubeCFrame, CubeSize, SurfacePointVector3)
	local ScreenCorners = {}
	local OnScreenFlags = {}
	for Index, Corner in ipairs(WorldCorners) do
		local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(Corner)
		ScreenCorners[Index] = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
		OnScreenFlags[Index] = OnScreen
	end

	local EdgePairs = {
		{ 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 },
	}

	for LineIndex, Pair in ipairs(EdgePairs) do
		local StartIndex = Pair[1]
		local EndIndex = Pair[2]
		local Line = TargetCubeLines[LineIndex]
		if OnScreenFlags[StartIndex] and OnScreenFlags[EndIndex] then
			Line.From = ScreenCorners[StartIndex]
			Line.To = ScreenCorners[EndIndex]
			Line.Visible = true
		else
			Line.Visible = false
		end
	end
end

local function IsVisible(TargetPositionVector3, CharacterModel, PartInstance)
	local DirectionVector3 = TargetPositionVector3 - Camera.CFrame.Position
	local Result = WorkspaceService.Raycast(WorkspaceService, Camera.CFrame.Position, DirectionVector3, VisibilityRaycastParams)
	if Result then
		if PartInstance then
			return Result.Instance == PartInstance or Result.Instance:IsDescendantOf(CharacterModel)
		end
		return Result.Instance.IsDescendantOf(Result.Instance, CharacterModel)
	end
	return true
end

local function GetVisiblePointForPart(PartInstance, CharacterModel, MouseLocationVector2)
	local SubdivisionNumber = math.max(VisibleCheckSubdivisionsNumber, 1)
	local PartSize = PartInstance.Size
	local HalfSize = PartSize * 0.5
	local StepSize = Vector3.new(PartSize.X / SubdivisionNumber, PartSize.Y / SubdivisionNumber, PartSize.Z / SubdivisionNumber)
	local HalfStep = StepSize * 0.5
	local BestPointVector3 = nil
	local BestCubeCFrame = nil
	local BestCubeSize = nil
	local BestDistanceNumber = math.huge
	local Rotation = PartInstance.CFrame - PartInstance.CFrame.Position
	local ThicknessNumber = math.min(StepSize.X, StepSize.Y, StepSize.Z)

	local function EvaluateSurfacePoint(LocalPoint, LocalCenter, CellSize)
		local TargetPointVector3 = PartInstance.CFrame:PointToWorldSpace(LocalPoint)
		local ScreenPositionVector3, OnScreenBoolean = Camera.WorldToViewportPoint(Camera, TargetPointVector3)
		if not OnScreenBoolean then
			return
		end
		local ScreenPositionVector2 = Vector2.new(ScreenPositionVector3.X, ScreenPositionVector3.Y)
		local ScreenDistanceNumber = (ScreenPositionVector2 - MouseLocationVector2).Magnitude
		if ScreenDistanceNumber >= BestDistanceNumber then
			return
		end
		if not IsVisible(TargetPointVector3, CharacterModel, PartInstance) then
			return
		end
		BestDistanceNumber = ScreenDistanceNumber
		BestPointVector3 = TargetPointVector3
		BestCubeCFrame = CFrame.new(PartInstance.CFrame:PointToWorldSpace(LocalCenter)) * Rotation
		BestCubeSize = CellSize
	end

	for YIndex = 0, SubdivisionNumber - 1 do
		local YOffset = -HalfSize.Y + HalfStep.Y + StepSize.Y * YIndex
		for ZIndex = 0, SubdivisionNumber - 1 do
			local ZOffset = -HalfSize.Z + HalfStep.Z + StepSize.Z * ZIndex
			EvaluateSurfacePoint(
				Vector3.new(HalfSize.X, YOffset, ZOffset),
				Vector3.new(HalfSize.X - ThicknessNumber / 2, YOffset, ZOffset),
				Vector3.new(ThicknessNumber, StepSize.Y, StepSize.Z)
			)
			EvaluateSurfacePoint(
				Vector3.new(-HalfSize.X, YOffset, ZOffset),
				Vector3.new(-HalfSize.X + ThicknessNumber / 2, YOffset, ZOffset),
				Vector3.new(ThicknessNumber, StepSize.Y, StepSize.Z)
			)
		end
	end

	for XIndex = 0, SubdivisionNumber - 1 do
		local XOffset = -HalfSize.X + HalfStep.X + StepSize.X * XIndex
		for ZIndex = 0, SubdivisionNumber - 1 do
			local ZOffset = -HalfSize.Z + HalfStep.Z + StepSize.Z * ZIndex
			EvaluateSurfacePoint(
				Vector3.new(XOffset, HalfSize.Y, ZOffset),
				Vector3.new(XOffset, HalfSize.Y - ThicknessNumber / 2, ZOffset),
				Vector3.new(StepSize.X, ThicknessNumber, StepSize.Z)
			)
			EvaluateSurfacePoint(
				Vector3.new(XOffset, -HalfSize.Y, ZOffset),
				Vector3.new(XOffset, -HalfSize.Y + ThicknessNumber / 2, ZOffset),
				Vector3.new(StepSize.X, ThicknessNumber, StepSize.Z)
			)
		end
	end

	for XIndex = 0, SubdivisionNumber - 1 do
		local XOffset = -HalfSize.X + HalfStep.X + StepSize.X * XIndex
		for YIndex = 0, SubdivisionNumber - 1 do
			local YOffset = -HalfSize.Y + HalfStep.Y + StepSize.Y * YIndex
			EvaluateSurfacePoint(
				Vector3.new(XOffset, YOffset, HalfSize.Z),
				Vector3.new(XOffset, YOffset, HalfSize.Z - ThicknessNumber / 2),
				Vector3.new(StepSize.X, StepSize.Y, ThicknessNumber)
			)
			EvaluateSurfacePoint(
				Vector3.new(XOffset, YOffset, -HalfSize.Z),
				Vector3.new(XOffset, YOffset, -HalfSize.Z + ThicknessNumber / 2),
				Vector3.new(StepSize.X, StepSize.Y, ThicknessNumber)
			)
		end
	end

	if not BestPointVector3 then
		return nil
	end

	return {
		point = BestPointVector3,
		cubeCFrame = BestCubeCFrame,
		cubeSize = BestCubeSize,
	}
end

local function GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2, IgnoreFovBoolean)
	local WorldDistanceNumber = (PartInstance.Position - Camera.CFrame.Position).Magnitude
	if WorldDistanceNumber > MaxDistanceNumber then
		return nil
	end

	local ScreenPositionVector3, OnScreenBoolean = Camera.WorldToViewportPoint(Camera, PartInstance.Position)
	if not OnScreenBoolean then
		return nil
	end

	local ScreenPositionVector2 = Vector2.new(ScreenPositionVector3.X, ScreenPositionVector3.Y)
	local ScreenDistanceNumber = (ScreenPositionVector2 - MouseLocationVector2).Magnitude
	if not IgnoreFovBoolean and ScreenDistanceNumber > FovCircle.Radius then
		return nil
	end

	local TargetPointVector3 = PartInstance.Position
	local CubeCFrame = PartInstance.CFrame
	local CubeSize = PartInstance.Size
	if VisibleCheckEnabledBoolean then
		local VisibleTargetData = GetVisiblePointForPart(PartInstance, CharacterModel, MouseLocationVector2)
		if not VisibleTargetData then
			return nil
		end
		TargetPointVector3 = VisibleTargetData.point
		CubeCFrame = VisibleTargetData.cubeCFrame
		CubeSize = VisibleTargetData.cubeSize
	end

	ScreenPositionVector3, OnScreenBoolean = Camera.WorldToViewportPoint(Camera, TargetPointVector3)
	if not OnScreenBoolean then
		return nil
	end

	ScreenPositionVector2 = Vector2.new(ScreenPositionVector3.X, ScreenPositionVector3.Y)
	if not IgnoreFovBoolean and not IsPointInCircle(ScreenPositionVector2, MouseLocationVector2, FovCircle.Radius) then
		return nil
	end

	ScreenDistanceNumber = (ScreenPositionVector2 - MouseLocationVector2).Magnitude

	return {
		part = PartInstance,
		character = CharacterModel,
		point = TargetPointVector3,
		cubeCFrame = CubeCFrame,
		cubeSize = CubeSize,
		screen = ScreenPositionVector2,
		screenDistance = ScreenDistanceNumber,
	}
end

local function GetBestTargetForCharacter(CharacterModel, MouseLocationVector2)
	local ClosestDistanceNumber = math.huge
	local ClosestTargetData = nil

	local ClosestHeadDistanceNumber = math.huge
	local ClosestHeadTargetData = nil

	for _, PartInstance in ipairs(CharacterModel:GetChildren()) do
		if not PartInstance:IsA("BasePart") then
			continue
		end

		local TargetData = GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2)
		if not TargetData then
			continue
		end

		local PartNameLowerString = string.lower(PartInstance.Name)
		local IsHeadBoolean = string.find(PartNameLowerString, "head") ~= nil
		if IsHeadBoolean and TargetData.screenDistance < ClosestHeadDistanceNumber then
			ClosestHeadDistanceNumber = TargetData.screenDistance
			ClosestHeadTargetData = TargetData
		end

		if TargetData.screenDistance < ClosestDistanceNumber then
			ClosestDistanceNumber = TargetData.screenDistance
			ClosestTargetData = TargetData
		end
	end

	if HeadshotPriorityBoolean and ClosestHeadTargetData then
		return ClosestHeadTargetData
	end

	return ClosestTargetData
end

local function IsLockKeyHeld()
	if UseEKeyForLockOnBoolean then
		return UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.E)
	else
		return UserInputService.IsMouseButtonPressed(UserInputService, Enum.UserInputType.MouseButton2)
	end
end

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
	local Args = { ... }
	local Method = getnamecallmethod()

	if UseHookMethodBoolean and CurrentTargetPartInstance then
		if Method == "Raycast" and Self == WorkspaceService then
			local Origin = Args[1]
			local Direction = Args[2]

			local ShouldRedirect = true
			if AimbotRequireRmbBoolean then
				ShouldRedirect = IsLockKeyHeld()
			end

			if ShouldRedirect and CurrentTargetPartInstance then
				local TargetPosition = CurrentTargetPointVector3 or CurrentTargetPartInstance.Position
				local NewDirection = (TargetPosition - Origin).Unit * Direction.Magnitude
				Args[2] = NewDirection
			end

			return OldNamecall(Self, unpack(Args))
		elseif Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay" then
			local RayObject = Args[1]

			local ShouldRedirect = true
			if AimbotRequireRmbBoolean then
				ShouldRedirect = IsLockKeyHeld()
			end

			if ShouldRedirect and CurrentTargetPartInstance and RayObject then
				local TargetPosition = CurrentTargetPointVector3 or CurrentTargetPartInstance.Position
				local NewDirection = (TargetPosition - RayObject.Origin).Unit * RayObject.Direction.Magnitude
				Args[1] = Ray.new(RayObject.Origin, NewDirection)
			end

			return OldNamecall(Self, unpack(Args))
		end
	end

	return OldNamecall(Self, ...)
end)

RunService.RenderStepped.Connect(RunService.RenderStepped, function()
	local MouseLocationVector2 = UserInputService.GetMouseLocation(UserInputService)
	local MouseOverPartInstance = MouseObject.Target
	FovCircle.Position = MouseLocationVector2
	FovCircle.Visible = ShowFovCircleBoolean
	if CurrentTargetPartInstance and (not CurrentTargetPartInstance.Parent or not CurrentTargetCharacterModel or not CurrentTargetCharacterModel.Parent) then
		CurrentTargetPartInstance = nil
		CurrentTargetCharacterModel = nil
		CurrentTargetPlayerObject = nil
		CurrentTargetPointVector3 = nil
		CurrentTargetCubeCFrame = nil
		CurrentTargetCubeSize = nil
	end

	local LocalCharacterModel = LocalPlayer.Character
	if LocalCharacterModel ~= LastRaycastCharacterModel then
		if LocalCharacterModel then
			VisibilityRaycastParams.FilterDescendantsInstances = { LocalCharacterModel }
		else
			VisibilityRaycastParams.FilterDescendantsInstances = {}
		end
		LastRaycastCharacterModel = LocalCharacterModel
	end
	local TeamCheckEnabledBoolean = false
	local LocalTeamModel = nil
	local LocalTeamObject = nil

	if UseCustomTeamCheckBoolean then
		if LocalCharacterModel and LocalCharacterModel.Parent and LocalCharacterModel.Parent.Name ~= "Characters" then
			TeamCheckEnabledBoolean = true
			LocalTeamModel = LocalCharacterModel.Parent
		end
	else
		if LocalPlayer.Team ~= nil then
			TeamCheckEnabledBoolean = true
			LocalTeamObject = LocalPlayer.Team
		end
	end

	local ClosestDistanceNumber = math.huge
	local ClosestScreenPositionVector2 = nil
	local ClosestPartInstance = nil
	local ClosestCharacterModel = nil
	local ClosestPlayerObject = nil
	local ClosestTargetPointVector3 = nil
	local ClosestCubeCFrame = nil
	local ClosestCubeSize = nil

	local ClosestHeadDistanceNumber = math.huge
	local ClosestHeadScreenPositionVector2 = nil
	local ClosestHeadPartInstance = nil
	local ClosestHeadCharacterModel = nil
	local ClosestHeadPlayerObject = nil
	local ClosestHeadTargetPointVector3 = nil
	local ClosestHeadCubeCFrame = nil
	local ClosestHeadCubeSize = nil

	local FinalTargetPartInstance = nil
	local FinalTargetCharacterModel = nil
	local FinalTargetPlayerObject = nil
	local FinalTargetScreenPositionVector2 = nil
	local FinalTargetPointVector3 = nil
	local FinalTargetCubeCFrame = nil
	local FinalTargetCubeSize = nil
	local CurrentTargetValidBoolean = false
	local CurrentTargetDistanceNumber = nil
	local IndicatorScreenPositionVector2 = nil
	local IndicatorPointVector3 = nil
	local IndicatorCubeCFrame = nil
	local IndicatorCubeSize = nil
	local IndicatorPartInstance = nil
	local IndicatorCharacterModel = nil
	local ShouldSearchForNewTargetBoolean = true

	if CurrentTargetPartInstance and CurrentTargetCharacterModel and CurrentTargetCharacterModel.Parent then
		local Humanoid = CurrentTargetCharacterModel.FindFirstChildOfClass(CurrentTargetCharacterModel, "Humanoid")
		if Humanoid and Humanoid.Health > 0 then
			local TargetData = GetTargetDataForPart(CurrentTargetPartInstance, CurrentTargetCharacterModel, MouseLocationVector2, false)
			if TargetData then
				CurrentTargetValidBoolean = true
				CurrentTargetDistanceNumber = TargetData.screenDistance
				local BestTargetData = GetBestTargetForCharacter(CurrentTargetCharacterModel, MouseLocationVector2)
				if BestTargetData and BestTargetData.screenDistance < (CurrentTargetDistanceNumber - RetargetMinImprovementNumber) then
					FinalTargetPartInstance = BestTargetData.part
					FinalTargetCharacterModel = BestTargetData.character
					FinalTargetPlayerObject = CurrentTargetPlayerObject
					FinalTargetScreenPositionVector2 = BestTargetData.screen
					FinalTargetPointVector3 = BestTargetData.point
					FinalTargetCubeCFrame = BestTargetData.cubeCFrame
					FinalTargetCubeSize = BestTargetData.cubeSize
					IndicatorScreenPositionVector2 = BestTargetData.screen
					IndicatorPointVector3 = BestTargetData.point
					IndicatorCubeCFrame = BestTargetData.cubeCFrame
					IndicatorCubeSize = BestTargetData.cubeSize
					IndicatorPartInstance = BestTargetData.part
					IndicatorCharacterModel = BestTargetData.character
				else
					FinalTargetPartInstance = TargetData.part
					FinalTargetCharacterModel = TargetData.character
					FinalTargetPlayerObject = CurrentTargetPlayerObject
					FinalTargetScreenPositionVector2 = TargetData.screen
					FinalTargetPointVector3 = TargetData.point
					FinalTargetCubeCFrame = TargetData.cubeCFrame
					FinalTargetCubeSize = TargetData.cubeSize
					IndicatorScreenPositionVector2 = TargetData.screen
					IndicatorPointVector3 = TargetData.point
					IndicatorCubeCFrame = TargetData.cubeCFrame
					IndicatorCubeSize = TargetData.cubeSize
					IndicatorPartInstance = TargetData.part
					IndicatorCharacterModel = TargetData.character
				end
			end
		end
	end

	local CandidatePartInstance = nil
	local CandidateCharacterModel = nil
	local CandidatePlayerObject = nil
	local CandidateScreenPositionVector2 = nil
	local CandidatePointVector3 = nil
	local CandidateDistanceNumber = nil
	local CandidateCubeCFrame = nil
	local CandidateCubeSize = nil

	local NowNumber = tick()
	local AllowTargetSearchBoolean = ShouldSearchForNewTargetBoolean and (NowNumber - LastTargetSearchTimeNumber >= TargetSearchIntervalNumber)
	if AllowTargetSearchBoolean then
		LastTargetSearchTimeNumber = NowNumber
	end

	if AllowTargetSearchBoolean then
		for _, PlayerObject in ipairs(Players.GetPlayers(Players)) do
			if PlayerObject == LocalPlayer then
				continue
			end

			local CharacterModel = PlayerObject.Character
			if not CharacterModel then
				continue
			end

			local SameTeamBoolean = false
			if TeamCheckEnabledBoolean then
				if UseCustomTeamCheckBoolean then
					if LocalTeamModel and CharacterModel.Parent == LocalTeamModel then
						SameTeamBoolean = true
					end
				else
					if LocalTeamObject and PlayerObject.Team == LocalTeamObject then
						SameTeamBoolean = true
					end
				end
			end

			if SameTeamBoolean then
				continue
			end

			local Humanoid = CharacterModel.FindFirstChildOfClass(CharacterModel, "Humanoid")
			if not Humanoid or Humanoid.Health <= 0 then
				continue
			end

			for _, PartInstance in ipairs(CharacterModel:GetChildren()) do
				if not PartInstance:IsA("BasePart") then
					continue
				end

				local TargetData = GetTargetDataForPart(PartInstance, CharacterModel, MouseLocationVector2)
				if not TargetData then
					continue
				end

				local PartNameLowerString = string.lower(PartInstance.Name)
				local IsHeadBoolean = string.find(PartNameLowerString, "head") ~= nil
				if IsHeadBoolean and TargetData.screenDistance < ClosestHeadDistanceNumber then
					ClosestHeadDistanceNumber = TargetData.screenDistance
					ClosestHeadScreenPositionVector2 = TargetData.screen
					ClosestHeadPartInstance = TargetData.part
					ClosestHeadCharacterModel = TargetData.character
					ClosestHeadPlayerObject = PlayerObject
					ClosestHeadTargetPointVector3 = TargetData.point
					ClosestHeadCubeCFrame = TargetData.cubeCFrame
					ClosestHeadCubeSize = TargetData.cubeSize
				end

				if TargetData.screenDistance < ClosestDistanceNumber then
					ClosestDistanceNumber = TargetData.screenDistance
					ClosestScreenPositionVector2 = TargetData.screen
					ClosestPartInstance = TargetData.part
					ClosestCharacterModel = TargetData.character
					ClosestPlayerObject = PlayerObject
					ClosestTargetPointVector3 = TargetData.point
					ClosestCubeCFrame = TargetData.cubeCFrame
					ClosestCubeSize = TargetData.cubeSize
				end
			end
		end

		if HeadshotPriorityBoolean and ClosestHeadPartInstance then
			CandidatePartInstance = ClosestHeadPartInstance
			CandidateCharacterModel = ClosestHeadCharacterModel
			CandidatePlayerObject = ClosestHeadPlayerObject
			CandidateScreenPositionVector2 = ClosestHeadScreenPositionVector2
			CandidatePointVector3 = ClosestHeadTargetPointVector3
			CandidateCubeCFrame = ClosestHeadCubeCFrame
			CandidateCubeSize = ClosestHeadCubeSize
			CandidateDistanceNumber = ClosestHeadDistanceNumber
		elseif ClosestPartInstance then
			CandidatePartInstance = ClosestPartInstance
			CandidateCharacterModel = ClosestCharacterModel
			CandidatePlayerObject = ClosestPlayerObject
			CandidateScreenPositionVector2 = ClosestScreenPositionVector2
			CandidatePointVector3 = ClosestTargetPointVector3
			CandidateCubeCFrame = ClosestCubeCFrame
			CandidateCubeSize = ClosestCubeSize
			CandidateDistanceNumber = ClosestDistanceNumber
		end
	end

	if AllowTargetSearchBoolean then
		if not CurrentTargetValidBoolean and CandidatePartInstance then
			FinalTargetPartInstance = CandidatePartInstance
			FinalTargetCharacterModel = CandidateCharacterModel
			FinalTargetPlayerObject = CandidatePlayerObject
			FinalTargetScreenPositionVector2 = CandidateScreenPositionVector2
			FinalTargetPointVector3 = CandidatePointVector3
			FinalTargetCubeCFrame = CandidateCubeCFrame
			FinalTargetCubeSize = CandidateCubeSize
		elseif CurrentTargetValidBoolean and CandidatePartInstance and CandidateDistanceNumber then
			if CandidateDistanceNumber < (CurrentTargetDistanceNumber - RetargetMinImprovementNumber) then
				FinalTargetPartInstance = CandidatePartInstance
				FinalTargetCharacterModel = CandidateCharacterModel
				FinalTargetPlayerObject = CandidatePlayerObject
				FinalTargetScreenPositionVector2 = CandidateScreenPositionVector2
				FinalTargetPointVector3 = CandidatePointVector3
				FinalTargetCubeCFrame = CandidateCubeCFrame
				FinalTargetCubeSize = CandidateCubeSize
			end
		end
	end

	if not CurrentTargetValidBoolean and not FinalTargetPartInstance then
		CurrentTargetPartInstance = nil
		CurrentTargetCharacterModel = nil
		CurrentTargetPlayerObject = nil
		CurrentTargetPointVector3 = nil
		CurrentTargetCubeCFrame = nil
		CurrentTargetCubeSize = nil
	end

	if FinalTargetPartInstance and FinalTargetScreenPositionVector2 then
		local NewTargetPointVector3 = FinalTargetPointVector3 or FinalTargetPartInstance.Position
		if CurrentTargetPartInstance ~= FinalTargetPartInstance or CurrentTargetPointVector3 ~= NewTargetPointVector3 then
			CurrentTargetPartInstance = FinalTargetPartInstance
			CurrentTargetCharacterModel = FinalTargetCharacterModel
			CurrentTargetPlayerObject = FinalTargetPlayerObject
			CurrentTargetPointVector3 = NewTargetPointVector3
			CurrentTargetCubeCFrame = FinalTargetCubeCFrame
			CurrentTargetCubeSize = FinalTargetCubeSize
		end
	end

	if not IndicatorScreenPositionVector2 and CandidateScreenPositionVector2 and CandidatePointVector3 then
		IndicatorScreenPositionVector2 = CandidateScreenPositionVector2
		IndicatorPointVector3 = CandidatePointVector3
		IndicatorCubeCFrame = CandidateCubeCFrame
		IndicatorCubeSize = CandidateCubeSize
		IndicatorPartInstance = CandidatePartInstance
		IndicatorCharacterModel = CandidateCharacterModel
	end

	if IndicatorScreenPositionVector2 and IndicatorPointVector3 and IndicatorPartInstance and ShowTargetLineBoolean then
		TargetLine.From = MouseLocationVector2
		TargetLine.To = IndicatorScreenPositionVector2
		TargetLine.Visible = true
		local CubeCFrame = IndicatorCubeCFrame or IndicatorPartInstance.CFrame
		local CubeSize = IndicatorCubeSize or GetCubeSize(IndicatorPartInstance)
		UpdateTargetCube(CubeCFrame, CubeSize, IndicatorPointVector3)
	else
		TargetLine.Visible = false
		SetTargetCubeVisible(false)
	end

	if CurrentTargetPartInstance then
		local TargetPositionVector3 = CurrentTargetPointVector3 or CurrentTargetPartInstance.Position

		local ShouldAimbotBoolean = true
		if AimbotRequireRmbBoolean then
			ShouldAimbotBoolean = IsLockKeyHeld()
		end

		if ShouldAimbotBoolean and UseCameraMethodBoolean then
			local CameraPositionVector3 = Camera.CFrame.Position
			local DirectionVector3 = (TargetPositionVector3 - CameraPositionVector3).Unit
			local CurrentLookVector = Camera.CFrame.LookVector
			local SmoothedLookVector = CurrentLookVector:Lerp(DirectionVector3, AimbotSmoothingNumber)
			Camera.CFrame = CFrame.new(CameraPositionVector3, CameraPositionVector3 + SmoothedLookVector)
		end

		local ScopeAllowedBoolean = true
		if UseCustomTeamCheckBoolean then
			local PlayerGui = LocalPlayer.FindFirstChild(LocalPlayer, "PlayerGui")
			local MainUI = PlayerGui and PlayerGui.FindFirstChild(PlayerGui, "MainUI")
			local ScopeObject = MainUI and MainUI.FindFirstChild(MainUI, "Scope")
			ScopeAllowedBoolean = ScopeObject and ScopeObject.Visible or false
		end

		if AutoFireEnabledBoolean and ShouldAimbotBoolean and CurrentTargetCharacterModel and MouseObject.Target and ScopeAllowedBoolean then
			if MouseObject.Target.IsDescendantOf(MouseObject.Target, CurrentTargetCharacterModel) then
				local NowNumber = tick()
				if NowNumber - LastAutoFireTimeNumber >= AutoFireCooldownNumber then
					LastAutoFireTimeNumber = NowNumber
					VirtualInputManager.SendMouseButtonEvent(VirtualInputManager, MouseLocationVector2.X, MouseLocationVector2.Y, 0, true, nil, 0)
					VirtualInputManager.SendMouseButtonEvent(VirtualInputManager, MouseLocationVector2.X, MouseLocationVector2.Y, 0, false, nil, 0)
				end
			end
		end
	end
end)
