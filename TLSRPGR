local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = PlayersService.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local KillAuraEnabled = true

local Cooldown = 0

local function Dragify(FrameObject)
	FrameObject.Active = true

	local Dragging = false
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(InputObject)
		local Delta = InputObject.Position - DragStart
		FrameObject.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end

	FrameObject.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = InputObject.Position
			StartPosition = FrameObject.Position

			InputObject.Changed:Connect(function()
				if InputObject.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	FrameObject.InputChanged:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseMovement or InputObject.UserInputType == Enum.UserInputType.Touch then
			DragInput = InputObject
		end
	end)

	UserInputService.InputChanged:Connect(function(InputObject)
		if InputObject == DragInput and Dragging then
			Update(InputObject)
		end
	end)
end

local KillAuraGui = Instance.new("ScreenGui")
KillAuraGui.Name = "KillAuraGui"
KillAuraGui.ResetOnSpawn = false
KillAuraGui.Parent = gethui() or PlayerGui

local KillAuraFrame = Instance.new("Frame")
KillAuraFrame.Name = "KillAuraFrame"
KillAuraFrame.AnchorPoint = Vector2.new(0, 0.5)
KillAuraFrame.Position = UDim2.new(0, 20, 0.15, 0)
KillAuraFrame.Size = UDim2.new(0, 220, 0, 90)
KillAuraFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KillAuraFrame.BorderSizePixel = 0
KillAuraFrame.Parent = KillAuraGui

local KillAuraFrameCorner = Instance.new("UICorner")
KillAuraFrameCorner.CornerRadius = UDim.new(0, 12)
KillAuraFrameCorner.Parent = KillAuraFrame

local KillAuraTitle = Instance.new("TextLabel")
KillAuraTitle.Name = "KillAuraTitle"
KillAuraTitle.BackgroundTransparency = 1
KillAuraTitle.Position = UDim2.new(0, 12, 0, 10)
KillAuraTitle.Size = UDim2.new(1, -24, 0, 24)
KillAuraTitle.Font = Enum.Font.GothamBold
KillAuraTitle.Text = "Kill Aura"
KillAuraTitle.TextSize = 18
KillAuraTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KillAuraTitle.TextXAlignment = Enum.TextXAlignment.Left
KillAuraTitle.Parent = KillAuraFrame

local KillAuraToggle = Instance.new("TextButton")
KillAuraToggle.Name = "KillAuraToggle"
KillAuraToggle.AnchorPoint = Vector2.new(1, 0.5)
KillAuraToggle.Position = UDim2.new(1, -12, 0.65, 0)
KillAuraToggle.Size = UDim2.new(0, 90, 0, 34)
KillAuraToggle.BackgroundColor3 = Color3.fromRGB(70, 160, 90)
KillAuraToggle.BorderSizePixel = 0
KillAuraToggle.Font = Enum.Font.GothamBold
KillAuraToggle.Text = "ON"
KillAuraToggle.TextSize = 14
KillAuraToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
KillAuraToggle.Parent = KillAuraFrame

local KillAuraToggleCorner = Instance.new("UICorner")
KillAuraToggleCorner.CornerRadius = UDim.new(0, 10)
KillAuraToggleCorner.Parent = KillAuraToggle

local KillAuraStatus = Instance.new("TextLabel")
KillAuraStatus.Name = "KillAuraStatus"
KillAuraStatus.BackgroundTransparency = 1
KillAuraStatus.Position = UDim2.new(0, 12, 0, 44)
KillAuraStatus.Size = UDim2.new(1, -120, 0, 20)
KillAuraStatus.Font = Enum.Font.Gotham
KillAuraStatus.Text = "Status: Enabled"
KillAuraStatus.TextSize = 14
KillAuraStatus.TextColor3 = Color3.fromRGB(170, 170, 170)
KillAuraStatus.TextXAlignment = Enum.TextXAlignment.Left
KillAuraStatus.Parent = KillAuraFrame

local function UpdateKillAuraUi()
	if KillAuraEnabled then
		KillAuraToggle.BackgroundColor3 = Color3.fromRGB(70, 160, 90)
		KillAuraToggle.Text = "ON"
		KillAuraStatus.Text = "Status: Enabled"
	else
		KillAuraToggle.BackgroundColor3 = Color3.fromRGB(160, 70, 70)
		KillAuraToggle.Text = "OFF"
		KillAuraStatus.Text = "Status: Disabled"
	end
end

KillAuraToggle.MouseButton1Click:Connect(function()
	KillAuraEnabled = not KillAuraEnabled
	UpdateKillAuraUi()
end)

UpdateKillAuraUi()
Dragify(KillAuraFrame)

RunService.RenderStepped:Connect(function(Delta)
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Cooldown += Delta

    if Cooldown > 0.1 then
        Cooldown = 0
        local Target = nil
        local TargetMagnitudeDistance = 50
        local Weapon = Character:FindFirstChildWhichIsA("Tool")
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            for _, Descendant in WorkspaceService["Mobs "]:GetDescendants() do
                if Descendant.ClassName == "TouchTransmitter" then
                    Descendant:Destroy()
                end

                if Descendant:FindFirstChild("HumanoidRootPart")
                    and (Descendant.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude < TargetMagnitudeDistance
                    and Descendant:FindFirstChild("Humanoid")
                    and Descendant.Humanoid.Health > 0 then

                    Target = Descendant
                    TargetMagnitudeDistance = (Descendant.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                end
            end
        end

        if KillAuraEnabled and Target and Target:FindFirstChild("HumanoidRootPart") and Weapon and Weapon:FindFirstChild("Handle") then
            Character.SwordDamage:FireServer(Target.Humanoid,Weapon,1,0,Weapon.Handle.Size,Weapon.Grip.Position)
        end
    end
end)

local PortalsFolder = WorkspaceService:WaitForChild("Portals")

local PortalsGui = Instance.new("ScreenGui")
PortalsGui.Name = "PortalsGui"
PortalsGui.ResetOnSpawn = false
PortalsGui.Parent = gethui() or PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0, 0.5)
MainFrame.Position = UDim2.new(0, 20, 0.5, 0)
MainFrame.Size = UDim2.new(0, 360, 0, 460)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = PortalsGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 14, 0, 10)
Title.Size = UDim2.new(1, -28, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "Rebirth Portals"
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 14, 0, 38)
SubTitle.Size = UDim2.new(1, -28, 0, 18)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "Rebirth Portal Requirements"
SubTitle.TextSize = 14
SubTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = MainFrame

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Position = UDim2.new(0, 14, 0, 62)
Divider.Size = UDim2.new(1, -28, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Name = "ListFrame"
ListFrame.Position = UDim2.new(0, 14, 0, 76)
ListFrame.Size = UDim2.new(1, -28, 1, -90)
ListFrame.BackgroundTransparency = 1
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 6
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 10)
ListLayout.Parent = ListFrame

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 2)
ListPadding.PaddingBottom = UDim.new(0, 2)
ListPadding.Parent = ListFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Position = UDim2.new(1, -12, 0, 12)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
	PortalsGui.Enabled = not PortalsGui.Enabled
end)

local function MakePortalRow(PortalName, RebirthRequired, Tele2Part, LayoutOrder)
	local Row = Instance.new("Frame")
	Row.Name = "PortalRow"
	Row.Size = UDim2.new(1, 0, 0, 72)
	Row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	Row.BorderSizePixel = 0
	Row.LayoutOrder = LayoutOrder or 0
	Row.Parent = ListFrame

	local RowCorner = Instance.new("UICorner")
	RowCorner.CornerRadius = UDim.new(0, 10)
	RowCorner.Parent = Row

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "NameLabel"
	NameLabel.BackgroundTransparency = 1
	NameLabel.Position = UDim2.new(0, 12, 0, 10)
	NameLabel.Size = UDim2.new(1, -140, 0, 22)
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Text = tostring(PortalName)
	NameLabel.TextSize = 16
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Parent = Row

	local RebirthLabel = Instance.new("TextLabel")
	RebirthLabel.Name = "RebirthLabel"
	RebirthLabel.BackgroundTransparency = 1
	RebirthLabel.Position = UDim2.new(0, 12, 0, 36)
	RebirthLabel.Size = UDim2.new(1, -140, 0, 20)
	RebirthLabel.Font = Enum.Font.Gotham
	RebirthLabel.Text = "Rebirth Required: " .. tostring(RebirthRequired)
	RebirthLabel.TextSize = 14
	RebirthLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
	RebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
	RebirthLabel.Parent = Row

	local TeleportButton = Instance.new("TextButton")
	TeleportButton.Name = "TeleportButton"
	TeleportButton.AnchorPoint = Vector2.new(1, 0.5)
	TeleportButton.Position = UDim2.new(1, -12, 0.5, 0)
	TeleportButton.Size = UDim2.new(0, 110, 0, 38)
	TeleportButton.BackgroundColor3 = Color3.fromRGB(45, 90, 170)
	TeleportButton.BorderSizePixel = 0
	TeleportButton.Font = Enum.Font.GothamBold
	TeleportButton.Text = "Teleport"
	TeleportButton.TextSize = 14
	TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TeleportButton.Parent = Row

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 10)
	ButtonCorner.Parent = TeleportButton

	if not Tele2Part then
		TeleportButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		TeleportButton.Text = "No tele2"
		TeleportButton.AutoButtonColor = false
	else
		TeleportButton.MouseButton1Click:Connect(function()
			if not (Tele2Part and Tele2Part.Parent) then
				return
			end

			local CharacterLocal = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local HumanoidRootPart = CharacterLocal:WaitForChild("HumanoidRootPart")

			local BaseCFrame = Tele2Part.CFrame:ToWorldSpace(CFrame.new(0, 0, 0))
			local BasePosition = BaseCFrame.Position
			local _, BaseYaw, _ = BaseCFrame:ToEulerAnglesYXZ()

			local RaycastParamsObject = RaycastParams.new()
			RaycastParamsObject.FilterType = Enum.RaycastFilterType.Exclude
			RaycastParamsObject.FilterDescendantsInstances = { CharacterLocal, Tele2Part }
			RaycastParamsObject.IgnoreWater = true

			local function IsPointInsideExpandedPart(Point, Part, PaddingStuds)
				if not (Part and Part:IsA("BasePart")) then
					return false
				end

				local LocalPoint = Part.CFrame:PointToObjectSpace(Point)
				local HalfSize = Part.Size * 0.5
				local PaddingVector = Vector3.new(PaddingStuds, PaddingStuds, PaddingStuds)
				local Expanded = HalfSize + PaddingVector

				return math.abs(LocalPoint.X) <= Expanded.X and math.abs(LocalPoint.Y) <= Expanded.Y and math.abs(LocalPoint.Z) <= Expanded.Z
			end

			local MaxOffset = 16
			local StepSize = 1

			local Offsets = {}
			for X = -MaxOffset, MaxOffset, StepSize do
				for Z = -MaxOffset, MaxOffset, StepSize do
					table.insert(Offsets, Vector3.new(X, 0, Z))
				end
			end

			table.sort(Offsets, function(A, B)
				local DistanceA = (A.X * A.X) + (A.Z * A.Z)
				local DistanceB = (B.X * B.X) + (B.Z * B.Z)
				if DistanceA == DistanceB then
					if A.X == B.X then
						return A.Z < B.Z
					end
					return A.X < B.X
				end
				return DistanceA < DistanceB
			end)

			local TouchPadding = 5
			local MinDistanceFromTele2 = 8

			local SafeCFrame = nil

			for _, Offset in ipairs(Offsets) do
				local CandidatePosition = BasePosition + Offset

				local DistanceFromTele2 = (CandidatePosition - Tele2Part.Position).Magnitude
				if DistanceFromTele2 < MinDistanceFromTele2 then
					continue
				end
				if IsPointInsideExpandedPart(CandidatePosition, Tele2Part, TouchPadding) then
					continue
				end

				local RayOrigin = CandidatePosition + Vector3.new(0, 10, 0)
				local RayDirection = Vector3.new(0, -500, 0)

				local Result = WorkspaceService:Raycast(RayOrigin, RayDirection, RaycastParamsObject)
				if Result and Result.Instance and Result.Instance:IsA("BasePart") then
					if Result.Instance ~= Tele2Part then
						local SafePosition = Vector3.new(CandidatePosition.X, Result.Position.Y + 3, CandidatePosition.Z)

						local DistanceFromTele2Safe = (SafePosition - Tele2Part.Position).Magnitude
						if DistanceFromTele2Safe < MinDistanceFromTele2 then
							continue
						end
						if IsPointInsideExpandedPart(SafePosition, Tele2Part, TouchPadding) then
							continue
						end

						local CandidateCFrame = CFrame.new(SafePosition) * CFrame.Angles(0, BaseYaw, 0)
						local DistanceFromCurrent = (HumanoidRootPart.Position - SafePosition).Magnitude
						if DistanceFromCurrent < 100000 then
							SafeCFrame = CandidateCFrame
							break
						end
					end
				end
			end

			if SafeCFrame then
				HumanoidRootPart.CFrame = SafeCFrame
			end
		end)
	end
end

local function RefreshPortalsUi()
	for _, Child in ipairs(ListFrame:GetChildren()) do
		if Child:IsA("Frame") then
			Child:Destroy()
		end
	end

	local PortalsData = {}

	for _, Descendant in ipairs(PortalsFolder:GetDescendants()) do
		if Descendant:IsA("IntValue") and Descendant.Name == "Rebirth" then
			local PortalName = "Unknown Portal"
			if Descendant.Parent and Descendant.Parent.Parent then
				PortalName = Descendant.Parent.Parent.Name
			end

			local RebirthRequired = Descendant.Value

			local Tele2Part = nil
			if Descendant.Parent then
				local DirectTele2 = Descendant.Parent:FindFirstChild("tele2")
				if DirectTele2 and DirectTele2:IsA("BasePart") then
					Tele2Part = DirectTele2
				else
					local DeepTele2 = Descendant.Parent:FindFirstChild("tele2", true)
					if DeepTele2 and DeepTele2:IsA("BasePart") then
						Tele2Part = DeepTele2
					end
				end
			end

			table.insert(PortalsData, {
				PortalName = PortalName,
				RebirthRequired = RebirthRequired,
				Tele2Part = Tele2Part,
			})
		end
	end

	table.sort(PortalsData, function(A, B)
		if A.RebirthRequired == B.RebirthRequired then
			return tostring(A.PortalName) < tostring(B.PortalName)
		end
		return A.RebirthRequired < B.RebirthRequired
	end)

	for Index, Data in ipairs(PortalsData) do
		MakePortalRow(Data.PortalName, Data.RebirthRequired, Data.Tele2Part, Index)
	end
end

RefreshPortalsUi()
Dragify(MainFrame)

PortalsFolder.DescendantAdded:Connect(function(Obj)
	if Obj:IsA("IntValue") and Obj.Name == "Rebirth" then
		RefreshPortalsUi()
	end
end)

PortalsFolder.DescendantRemoving:Connect(function(Obj)
	if Obj:IsA("IntValue") and Obj.Name == "Rebirth" then
		RefreshPortalsUi()
	end
end)
