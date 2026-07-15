local rebirthRequirements = {
	[1] = 10,
	[2] = 50,
	[3] = 400,
	[4] = 2000,
	[5] = 10000
}

local function roundToNearest(value, step)
	return math.floor((value + step / 2) / step) * step
end

local function getRebirthCost(player)

	local rebirthCount = player:FindFirstChild("leaderstats").Rebirth.Value
	local halfRebirthAmount = player:FindFirstChild("DevProducts").HalfRebirth.Value

	if rebirthRequirements[rebirthCount + 1] then
		local predefined = rebirthRequirements[rebirthCount + 1] * .5^halfRebirthAmount
		if predefined then
			return predefined
		end
	end

	local base = rebirthRequirements[#rebirthRequirements] * .6
	local exponent = (rebirthCount * math.log(2) / math.log(rebirthCount)) * 1.3

	local cost = base * ((rebirthCount - (#rebirthRequirements-2)) ^ exponent) * .5^halfRebirthAmount
	local digitAmount = #tostring(math.floor(cost))
	return roundToNearest(cost, tonumber("1e" .. (digitAmount - 1)))
end

return getRebirthCost