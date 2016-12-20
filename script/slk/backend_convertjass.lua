local lpeg = require 'lpeg'
local line_count
local wts

local function fwts(str)
    return wts:load(str)
end

lpeg.locale(lpeg)
local S = lpeg.S
local P = lpeg.P
local R = lpeg.R
local C = lpeg.C
local Cs = lpeg.Cs

local nl1  = P'\r\n' + S'\r\n'
local com  = P'//' * (1-nl1)^0
local nl   = com^0 * nl1 / function() line_count = line_count + 1 end
local quo  = P'"'
local esc  = P'\\'
local num  = R'09'
local str1 = esc * P(1) + (1-quo)
local str  = quo * (nl1 + str1)^0 * quo
local wst  = quo * ('TRIGSTR_' * num^3 / fwts) * quo

local pjass = Cs((nl + wst + str + 1)^0)

return function (w2l, archive, wts_)
    local name = 'war3map.j'
    local buf = archive:get(name)
    if not buf then
        name = 'scripts\\war3map.j'
        buf = archive:get(name)
        if not buf then
            return
        end
    end
    wts = wts_
    line_count = 0
    archive:set(name, pjass:match(buf))
end