--!strict

local AnimateR6 = require(script:WaitForChild("AnimateR6"))
local AnimateR15 = require(script:WaitForChild("AnimateR15"))
local ManualDirector = require(script:WaitForChild("ManualDirector"))
local ExportedTypes = require(script:WaitForChild("ExportedTypes"))

type AnimationEntity = ExportedTypes.AnimationEntityR6 | ExportedTypes.AnimationEntityR15
type SerializedAnimation = ExportedTypes.SerializedAnimation

local module = {}

local function animateInternal(
	parent: Instance,
	director: Humanoid | ExportedTypes.ManualHumanoid,
	performer: Humanoid?,
	serializedDefaultAnimations: { [string]: { SerializedAnimation } }?,
	onKeyFrameReached: ((entity: AnimationEntity, frameName: string) -> ())?,
	markers: { [string]: () -> () }?
): ExportedTypes.AnimateController
	local castedDirector = director :: Humanoid
	local actor = performer or castedDirector

	local animateModule = if actor.RigType == Enum.HumanoidRigType.R6 then AnimateR6 else AnimateR15

	if serializedDefaultAnimations then
		for name, serializedAnimations in serializedDefaultAnimations do
			animateModule.serializedDefaultAnimations[name] = serializedAnimations
		end
	end

	if onKeyFrameReached then
		(animateModule :: any).onKeyFrameReached = onKeyFrameReached
	end

	if markers then
		(animateModule :: any).markers = markers
	end

	local controller
	if actor.RigType == Enum.HumanoidRigType.R6 then
		controller = AnimateR6.animate(parent, castedDirector, actor)
	else
		controller = AnimateR15.animate(parent, castedDirector, actor)
	end

	return controller
end

function module.animate(
	parent: Instance,
	director: Humanoid,
	performer: Humanoid?,
	serializedDefaultAnimations: { [string]: { SerializedAnimation } }?,
	onKeyFrameReached: ((entity: AnimationEntity, frameName: string) -> ())?,
	markers: { [string]: () -> () }?
): ExportedTypes.AnimateController
	return animateInternal(parent, director, performer, serializedDefaultAnimations, onKeyFrameReached, markers)
end

function module.animateManually(parent: Instance, performer: Humanoid): ExportedTypes.AnimateControllerManually
	local director = ManualDirector.create()
	local controller: any = animateInternal(parent, director.humanoid, performer)

	controller.fireState = director.fireState
	controller.setMovement = director.setMovement

	return controller :: ExportedTypes.AnimateControllerManually
end

return module
