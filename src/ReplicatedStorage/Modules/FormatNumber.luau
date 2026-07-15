local formatNumber = function(num)
	local suffixes = {
		"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No",       -- 10^3 to 10^33
		"De", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", -- 10^36 to 10^63
		"Vg", "Uv", "Dv", "Tv", "Qav", "Qiv", "Sxv", "Spv", "Ocv", "Nov", -- 10^66 to 10^93
		"Tg", "Utg", "Dtg", "Ttg", "Qatg", "Qitg", "Sxtg", "Sptg", "Octg", "Notg", -- 10^96 to 10^123
		"Qag", "Uqag", "Dqag", "Tqag", "QaQag", "QiQag", "SxQag", "SpQag", "OcQag", "NoQag", -- 10^126 to 10^153
		"Sg", "Usg", "Dsg", "Tsg", "Qasg", "Qisg", "Sxsg", "Spsg", "Ocsg", "Nosg", -- 10^156 to 10^183
		"Spg", "Uspg", "Dspg", "Tspg", "Qaspg", "Qispg", "Sxspg", "Spspg", "Ocspg", "Nospg", -- 10^186 to 10^213
		"Og", "Uog", "Dog", "Tog", "Qaog", "Qiog", "Sxog", "Spog", "Ocog", "Noog", -- 10^216 to 10^243
		"Ng", "Ung", "Dng", "Tng", "Qang", "Qing", "Sxng", "Spng", "Ocng", "Nong", -- 10^246 to 10^273
		"Ce", "Uce", "Dce", "Tce", "Qace", "Qice", "Sxce", "Spce", "Occe", "Noce"  -- 10^276 to 10^303
	}

	local original = num
	local i = 1
	while num >= 1000 and i < #suffixes do
		num = num / 1000
		i += 1
	end

	if i <= #suffixes then
		-- floor to one decimal place instead of rounding
		local floored = math.floor(num * 10) / 10
		local formatted = tostring(floored)
		-- ensure ".0" removed
		if formatted:sub(-2) == ".0" then
			formatted = formatted:sub(1, -3)
		end
		return formatted .. suffixes[i]
	else
		-- fall back to scientific notation
		local exponent = math.floor(math.log10(original))
		local mantissa = math.floor(original / (10 ^ (exponent - 1))) / 10  -- floor to 1 decimal
		return string.format("%.1fe+%d", mantissa, exponent)
	end
end

return formatNumber