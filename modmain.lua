modimport("strings.lua") -- 加载翻译文件

-- 语言检测
local lang = GetModConfigData("lang") or "auto"
if lang == "auto" then
    lang = GLOBAL.LanguageTranslator.defaultlang
end

local chinese_languages =
{
    zh = "zh", -- Chinese for Steam
    zhr = "zh", -- Chinese for WeGame
    ch = "zh", -- Chinese mod
    chs = "zh", -- Chinese mod
    sc = "zh", -- simple Chinese
    zht = "zh", -- traditional Chinese for Steam
	tc = "zh", -- traditional Chinese
	cht = "zh", -- Chinese mod
}

if chinese_languages[lang] ~= nil then
    lang = chinese_languages[lang]
elseif not GLOBAL.STRINGS.SAVE_ANNOUNCE[lang] then -- 找不到对应语言的翻译才用英文
    lang = "en"
end


AddModRPCHandler("ANNOUNCE","dusk", function(player,str)
    if GetModConfigData("dusk_announce") then
        player.components.talker:Say(str) -- 为了让所有人看得到Say 需要交给服务器执行
    end
end)


if GLOBAL.TheNet:GetIsServer() then
    AddClientModRPCHandler("ANNOUNCE", "save", function(str) end) -- 保存前提示 RPC
    AddShardModRPCHandler("ANNOUNCE", "shard", function(shardId,str) -- 多层世界 保存提示数据传输
        if GLOBAL.TheShard:GetShardId() ~= tostring(shardId) then
            SendModRPCToClient(CLIENT_MOD_RPC["ANNOUNCE"]["save"], id_table, str)
        end
    end)
end

AddPrefabPostInit("world",function(inst)

-- 客户端部分
if GLOBAL.TheNet:GetIsClient() then
    -- 黄昏宣告
    local function updatephase()
        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.prefab and not inst:HasTag("cave") and GetModConfigData("dusk_announce") then
        local phase = inst.state.phase
        local prefab= GLOBAL.ThePlayer.prefab
            level= phase == "day" and 1 or phase == "dusk" and 2 or 3
            if level == 2 then
                SendModRPCToServer(MOD_RPC["ANNOUNCE"]["dusk"], GLOBAL.GetString(prefab, "ANNOUNCE_DUSK")) -- 获取官方的黄昏宣告内容并发送至服务器执行
            end
        end
    end
    inst:WatchWorldState("phase", updatephase)
    -- 保存前提示
    AddClientModRPCHandler("ANNOUNCE", "save", function(str)
        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.prefab then
            GLOBAL.ThePlayer.components.talker:Say(str)
        end
    end)
end
-- 服务器自动保存部分
if GLOBAL.TheNet:GetIsServer() and not GLOBAL.TheShard:IsSecondary() then
    inst:DoTaskInTime(0, function(inst)
        inst:PushEvent("ms_setautosaveenabled", false) -- 关闭DST自动保存功能
    end)

    if GetModConfigData("save_time") == false then return
    else min = GetModConfigData("save_time")
    end

    inst:DoPeriodicTask(min*60,function()
        -- inst:PushEvent("ms_save") -- 保存存档！
    end)

    -- 保存前的提示
    TIME = GetModConfigData("save_prompt")
    local SAVE_ANNOUNCE = GLOBAL.STRINGS.SAVE_ANNOUNCE[lang]:format(TIME) -- 提示内容
    if GetModConfigData("save_time") ~= false and GetModConfigData("save_prompt") ~= false and GetModConfigData("save_time")*60 > GetModConfigData("save_prompt") then
        inst:DoTaskInTime(min*60-TIME, function(inst) -- 首次执行
            SendModRPCToClient(CLIENT_MOD_RPC["ANNOUNCE"]["save"], id_table, SAVE_ANNOUNCE)
            SendModRPCToShard(GetShardModRPC("ANNOUNCE","shard"),nil, SAVE_ANNOUNCE)
                inst:DoPeriodicTask(min*60,function() -- 循环执行
                    SendModRPCToClient(CLIENT_MOD_RPC["ANNOUNCE"]["save"], id_table, SAVE_ANNOUNCE)
                    SendModRPCToShard(GetShardModRPC("ANNOUNCE","shard"),nil, SAVE_ANNOUNCE)
                end)
        end)
    end
end

end)