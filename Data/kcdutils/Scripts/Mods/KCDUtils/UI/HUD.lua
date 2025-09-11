KCDUtils = KCDUtils or {}

---@class KCDUtilsUI
KCDUtils.UI = KCDUtils.UI or {}

--- Shows a notification for reputation gained.
--- @param message string The message to display.
function KCDUtils.UI.ShowReputationGained(message)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowReputationChanged", 0, message)
end

--- Shows a notification for reputation lost.
--- @param message string The message to display.
function KCDUtils.UI.ShowReputationLost(message)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowReputationChanged", 1, message)
end

--- Shows a tutorial message on the HUD.
--- @param message string The tutorial message to display.
--- @param duration integer (optional) The duration to display the tutorial in milliseconds. Default is 8000 ms.
--- @param actionHintEnable boolean (optional) Whether to enable action hints. Default is false.
function KCDUtils.UI.ShowTutorial(message, duration, actionHintEnable)
    duration = duration or 8000
    actionHintEnable = actionHintEnable or false
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowTutorial", "KCDUtils_Tutorial", message, duration, actionHintEnable, 0, 0, false, "")
end

--- Hides a specific tutorial message by its ID.
--- @param id string The tutorial ID to hide.
function KCDUtils.UI.HideTutorial(id)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "HideTutorial", id)
end

--- Hides the currently displayed tutorial message.
function KCDUtils.UI.HideCurrentTutorial()
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "HideCurrentTutorial")
end

--- Shows a discovered codex entry.
--- @param name string Name of the location/POI/etc.
--- @param iconId string Icon ID if available.
--- @param perkId string Perk ID if available.
function KCDUtils.UI.ShowDiscoveredCodex(name, iconId, perkId)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowDiscoveredCodex", name, iconId, perkId)
end

--- Shows a discovered point of interest (POI).
--- @param type KCDUtilsDiscoveredPoiType|integer POI header type.
--- @param name string Name of the POI.
--- @param iconId string Icon ID.
--- @param perkId string Perk ID.
function KCDUtils.UI.ShowDiscoveredPoi(type, name, iconId, perkId)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowDiscoveredPoi", type, name, iconId, perkId)
end

--- Shows a discovered location.
--- @param type KCDUtilsDiscoveredLocationType|integer Location UI element type.
--- @param name string Name of the location.
--- @param iconId string Icon ID.
--- @param perkId string Perk ID.
function KCDUtils.UI.ShowDiscoveredLocation(type, name, iconId, perkId)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowDiscoveredLocation", type, name, iconId, perkId)
end

--- Hides the codex action hint from the HUD.
function KCDUtils.UI.HideCodexActionHint()
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "HideCodexActionHint")
end

--- Sets the HUD element for the current crime state.
--- @param state KCDUtilsCrimeState|integer The crime state value.
function KCDUtils.UI.SetCrimeState(state)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "SetCrimeState", state)
end

--- Sets the HUD element for the current crime recognizing value.
--- @param value integer Value from 0 to 9, interacts with the bunny ears.
function KCDUtils.UI.SetCrimeRecognizingValue(value)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "SetCrimeRecognizingValue", value)
end

--- Sets the HUD element for the current trespass state.
--- @param state KCDUtilsTrespassState|integer The trespass state value.
function KCDUtils.UI.SetTrespassState(state)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "SetTrespassState", state)
end

--- Sets the HUD element for the current wanted state.
--- @param state KCDUtilsWantedState|integer The wanted state value.
function KCDUtils.UI.SetWantedState(state)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "SetWantedState", state)
end

--- Shows an info text message on the HUD.
--- @param message string The info text to display.
--- @param priority integer Priority of the message.
--- @param duration integer Duration in milliseconds.
--- @param background boolean Whether to show a background shadow.
function KCDUtils.UI.ShowInfoText(message, priority, duration, background)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowInfoText", message, priority, duration, background)
end

--- Hides the currently displayed info text message.
function KCDUtils.UI.HideInfoText()
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "HideInfoText")
end

--- Sets the playing state for info text messages.
--- @param playing boolean Whether info text is playing.
--- @param flush boolean Whether to flush the info text.
function KCDUtils.UI.SetPlayingInfoText(playing, flush)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "SetPlayingInfoText", playing, flush)
end

--- Shows a notification for a used perk.
--- @param iconName string The icon name for the perk.
--- @param uiName string The UI name for the perk.
function KCDUtils.UI.ShowPerkUsed(iconName, uiName)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowPerkUsed", iconName, uiName)
end

--- Shows a notification for a newly gained perk.
--- @param iconName string The icon name for the perk.
--- @param uiName string The UI name for the perk.
function KCDUtils.UI.ShowPerkGained(iconName, uiName)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowPerkGained", iconName, uiName)
end

--- Shows a notification for a newly learned combo.
--- @param iconName string The icon name for the combo.
--- @param uiName string The UI name for the combo.
function KCDUtils.UI.ShowComboLearned(iconName, uiName)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowComboLearned", iconName, uiName)
end

--- Shows a notification message in the top right corner without an icon.
--- @param message string The notification message to display.
function KCDUtils.UI.ShowNotification(message)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowNotification", message)
end

--- Shows a skill check success notification.
--- @param skill string The skill name.
function KCDUtils.UI.ShowSkillCheckSuccess(skill)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowSkillCheckResult", skill, 1)
end

--- Shows a skill check failure notification.
--- @param skill string The skill name.
function KCDUtils.UI.ShowSkillCheckFail(skill)
    KCDUtils.UIAction.CallFunction(KCDUtils.Resources.UIActionElements.HUD, "ShowSkillCheckResult", skill, 0)
end

--- Subscribes to the system event for showing a codex action hint.
--- @param target any The target object.
--- @param eventName string The event name.
--- @param methodName string The method name to call.
function KCDUtils.UI.OnShowCodexActionHint(target, eventName, methodName)
    KCDUtils.Events.SubscribeSystemEvent(target, methodName, eventName)
end

-- #region Tooltip 
    --   <function name="ShowTooltip" funcname="fc_showTooltip">
    --     <param name="Text" desc="Tooltip from other UI" type="string" />
    --     <param name="X" desc="x position" type="int" />
    --     <param name="Y" desc="y position" type="int" />
    --   </function>

    --   <function name="UpdateTooltip" funcname="fc_updateTooltip">
    --     <param name="X" desc="x position" type="int" />
    --     <param name="Y" desc="y position" type="int" />
    --   </function>

    --   <function name="HideTooltip" funcname="fc_hideTooltip" />
    -- #endregion

-- #region Interactive dialogue
    --       <!-- Interactive dialogue - skillChecks -->
    --   <function name="SetSkillChecks" funcname="fc_setSkillChecks">
    --     <param name="Reputation" desc="enum" type="int" />
    --   </function>

    --   <function name="ClearSkillChecks" funcname="fc_clearSkillChecks" />
    -- #endregion

-- #region Tutorial

    --       <!-- Tutorial message -->
    --   <function name="ShowTutorial" funcname="fc_showTutorial">
    --     <param name="Id" desc="" type="string" />
    --     <param name="Text" desc="Tutorial message text to be set. (can be HTML)" type="string" />
    --     <param name="Duration" desc="" type="int" />
    --     <param name="InDialogue" desc="should synchronize with showing dialogue prompts" type="bool" />
    --     <param name="Priority" desc="" type="int" />
    --     <param name="Layout" desc="" type="int" />
    --     <param name="ActionHintEnable" desc="" type="bool" />
    --     <param name="OverlayLink" desc="" type="string" />
    --   </function>

--           <function name="HideTutorial" funcname="fc_hideTutorial" >
--         <param name="Id" desc="" type="string" />
--       </function>

--       <function name="HideCurrentTutorial" funcname="fc_hideCurrentTutorial" />
--       <function name="HideAllTutorials" funcname="fc_hideAllTutorials" />

-- #endregion

-- #region Discovered Messages

--       <!-- Discovered message -->
-- <function name="ShowDiscoveredCodex" funcname="fc_showDiscoveredCodex">
--   <param name="Name" desc="name of Location/POI/etc." type="string" />
--   <param name="IconId" desc="id of icon if exist" type="string" />
--   <param name="PerkId" desc="id of perk" type="string" />
-- </function>

-- <function name="ShowDiscoveredPoi" funcname="fc_showDiscoveredPoi">
--   <param name="Type" desc="enum define type Poi" type="int" />
--   <param name="Name" desc="name of Location/POI/etc." type="string" />
--   <param name="IconId" desc="id of icon if exist" type="string" />
--   <param name="PerkId" desc="id of perk" type="string" />
-- </function>

-- <function name="ShowDiscoveredLocation" funcname="fc_showDiscoveredLocation">
--   <param name="Type" desc="enum define type common or unique" type="int" />
--   <param name="Name" desc="name of Location" type="string" />
--   <param name="IconId" desc="id of icon if exist" type="string" />
--   <param name="PerkId" desc="id of perk" type="string" />
-- </function>

-- <function name="HideCodexActionHint" funcname="fc_hideCodexActionHint" />

-- #endregion

-- #region States

-- <!-- Crime state-->
-- <function name="SetCrimeState" funcname="fc_setCrimeState">
--   <param name="state" desc="0 nothing, ..." type="int" />
-- </function>

-- <function name="SetCrimeRecognizingValue" funcname="fc_setCrimeRecognizingValue">
--   <param name="value" desc="" type="int" />
-- </function>

-- <!-- Trespass state -->
-- <function name="SetTrespassState" funcname="fc_setTrespassState">
--   <param name="state" desc="0 for hide, 1 for state private area, 2 for trespassing" type="int" />
-- </function>

-- <!-- Wanted state -->
-- <function name="SetWantedState" funcname="fc_setWantedState">
--   <param name="state" desc="0 for hide, 1 for show" type="int" />
-- </function>

-- #endregion

-- #region Fader Dialog

-- <!-- Fader Dialog -->
-- <function name="SetFaderState" funcname="fc_setFaderState">
--   <param name="State" desc="0 on, 1 start, 2 stop, 3 off" type="int" />
--   <param name="Layout" desc="optional param for image" type="string" />
-- </function>

-- <function name="SetFullModeVignette" funcname="fc_setFullModeVignette">
--   <param name="Value" desc="0 to 1" type="float" />
-- </function>

-- #endregion

-- #region Hold Cursor

--  <!-- Set progress of hold cursor -->
--  <function name="SetProgress" funcname="fc_setProgress">
-- 	  <param name="Value" desc="Set progress" type="int" />
--    <param name="ActionId" desc="id of action hint" type="string" />
--    <param name="HintClass" desc="id of action hint" type="string" />
--   </function>

-- #endregion

-- #region Denial Cursor

--  <!-- Show denial cursor -->
--  <function name="ShowDenialAttack" funcname="fc_showDenialAttack" />

-- #endregion

-- #region Info Text

--  <!-- Info text -->
--  <function name="ShowInfoText" funcname="fc_showInfoText">
--    <param name="Text" desc="" type="string" />
--    <param name="Priority" desc="higher number is higher priority" type="int" />
--    <param name="Duration" desc="time in milisec" type="int" />
--    <param name="Background" desc="it has big shadow under text" type="bool" />
--  </function>

--  <function name="HideInfoText" funcname="fc_hideInfoText"/>

--  <function name="SetPlayingInfoText" funcname="fc_setPlayingInfoText">
--    <param name="Playing" desc="" type="bool" />
--    <param name="Flush" desc="" type="bool" />
--  </function>

-- #endregion

-- #region Objective Event

--  <!-- Objective event -->
--  <function name="ShowObjectiveEvent" funcname="fc_showObjectiveEvent">
--    <param name="Type" desc="Enum of event 0-6" type="int" />
--    <param name="Name" desc="Name of objective" type="string" />
--    <param name="QuestType" desc="main/side/..." type="int" />
--    <param name="QuestTrackingId" desc="" type="int" />
--    <param name="QuestId" desc="" type="string" />
--    <param name="QuestUiName" desc="" type="string" />
-- <param name="ObjectiveIndex" desc="" type="int" />
--    <param name="Tracker" desc="Objective progress values" type="string" />
--  </function>

-- #endregion

-- #region Fancy Event

--  <!-- Quest event -->
--  <function name="ShowQuestEvent" funcname="fc_showQuestEvent">
--    <param name="QuestId" desc="" type="string" />
--    <param name="Type" desc="Enum of event 0-6" type="int" />
--    <param name="Name" desc="Name of quest/objective" type="string" />
--    <param name="QuestType" desc="main/side/..." type="int" />
--     <param name="TrackingId" desc="none/blue/..." type="int" />  
--  </function>

--  <function name="SetPlayingFancyEvent" funcname="fc_setPlayingFancyEvent">
--    <param name="Playing" desc="" type="bool" />
--    <param name="Flush" desc="" type="bool" />
--  </function>

-- #endregion

-- #region Perk Events

--  <function name="ShowPerkUsed" funcname="fc_showPerkUsed">
--    <param name="IconName" desc="" type="string" />
--    <param name="UiName" desc="" type="string" />
--  </function>

--  <function name="ShowPerkGained" funcname="fc_showPerkGained">
--    <param name="IconName" desc="" type="string" />
--    <param name="UiName" desc="" type="string" />
--  </function>

--  <function name="ShowComboLearned" funcname="fc_showComboLearned">
--    <param name="IconName" desc="" type="string" />
--    <param name="UiName" desc="" type="string" />
--  </function>

--  <function name="ShowNotification" funcname="fc_showNotification">
--    <param name="infoText" desc="text" type="string" />
--  </function>

-- #endregion

-- #region Fast Travel Events

--  <!-- Fast travel result -->
--  <function name="ShowRandomEventResult" funcname="fc_showRandomEventResult">
--    <param name="Type" desc="Enum of event 0-2" type="int" />
--    <param name="Result" desc="Text of result" type="string" />
--    <param name="Name" desc="Name of event" type="string" />
--  </function>

-- #endregion

-- #region Skill Check Events

--  <!-- Skill check -->
--  <function name="ShowSkillCheckResult" funcname="fc_showSkillCheckResult">
--    <param name="Name" desc="Name of skillcheck" type="string" />
--    <param name="Result" desc="Enum of result: 0 fail, 1 succes" type="int" />
--  </function>

--  <function name="SetPlayingSkillCheckEvent" funcname="fc_setPlayingSkillCheckEvent">
--    <param name="Playing" desc="" type="bool" />
--    <param name="Flush" desc="" type="bool" />
--  </function>

-- #endregion

-- #region Items

--  <!-- Items count -->
--  <function name="ShowItemCount" funcname="fc_showItemCount">
--    <param name="Id" desc="" type="string" />
--    <param name="UiName" desc="" type="string" />
--    <param name="IconId" desc="" type="int" />
--    <param name="Count" desc="count of items" type="int" />
--  </function>

--  <function name="HideItemCount" funcname="fc_hideItemCount">
--    <param name="Id" desc="" type="string" />
--  </function>

--   <!-- Items transfer -->
--  <function name="ShowItemTransfer" funcname="fc_showItemTransfer">
--    <param name="ClassId" desc="" type="string" />
--    <param name="UiName" desc="" type="string" />
--    <param name="IconId" desc="" type="string" />
--    <param name="Count" desc="count of items" type="int" />
--    <param name="Direction" desc="to player = 0, from player = 1" type="int" />
--  </function>

--  <function name="SetPlayingItemTransferEvent" funcname="fc_setPlayingItemTransferEvent">
--    <param name="Playing" desc="" type="bool" />
--    <param name="Flush" desc="" type="bool" />
--  </function>

-- #endregion

-- #region Events

--  	<events>
--   <event name="OnShowCodexActionHint" fscommand="onShowCodexActionHint" desc="">
--     <param name="show" desc="" type="bool"/>
--     <param name="perkId" desc="" type="string"/>
--   </event>
--   <event name="OnShowTutorialActionHint" fscommand="onShowTutorialActionHint" desc="">
--     <param name="show" desc="" type="bool"/>
--     <param name="overlayLink" desc="" type="string"/>
--   </event>

--   <event name="OnShootingContestRemoved" fscommand="onShootingContestRemoved" desc="" />

--   <!-- Audio -->
--   <event name="OnPlayAudio" fscommand="onPlayAudio" desc="execute global audio trigger">
--     <param name="TriggerName" desc="" type="string"/>
--   </event>

--   <event name="OnStopAudio" fscommand="onStopAudio" desc="stop global audio trigger">
--     <param name="TriggerName" desc="" type="string"/>
--   </event>

--   <event name="OnSetVolumeAudio" fscommand="onSetVolumeAudio" desc="set volume via rtpc">
--     <param name="TriggerName" desc="" type="string"/>
--     <param name="Volume" desc="" type="float"/>
--   </event>

--   <!-- Buttons -->
--   <event name="GetButtonId" fscommand="getButtonId" desc="return button id from action name">
--     <param name="ActionName" desc="" type="string"/>
--   </event>

--   <event name="OnActionButtonActivated" fscommand="onActionButtonActivated" desc="button activated">
--     <param name="ActionName" desc="" type="string"/>
--     <param name="ActivationMode" desc="" type="int"/>
--   </event>

-- </events>

-- #endregion