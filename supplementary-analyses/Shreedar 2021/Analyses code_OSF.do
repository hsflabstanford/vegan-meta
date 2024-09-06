

** Veg choice - Chi-squared tests**

tab vegchoice tb1, chi2

tab vegchoice tb2, chi2

tab vegchoice tb3, chi2

** Veg choice - regression analyses **

//Model 1

logit vegchoice i.treatb2, vce(robust) or
logit vegchoice i.treatb2, vce(robust) 
test 1.treatb2 = 2.treatb2

local sdlist `sdlist' age i.male hhincome i.student i.political
local foodlist `foodlist' hungry pastweek_veg i.fpdiet 
logit vegchoice i.treat `foodlist' `sdlist', vce(robust) or
logit vegchoice i.treat `foodlist' `sdlist', vce(robust)
test

poisson past3d_veg2 i.treatb1b2, vce(cluster pid)
poisson past3d_veg2 i.treatb1b2 if check1pass==1 & check2pass==1, vce(cluster pid)
poisson past3d_veg2 i.treatb1b2 if check1pass==1 & check2pass==1 & nonvegdiet==1, vce(cluster pid)


// OTHER ANALYSES

local sdlist `sdlist' age i.male hhincome i.student i.political
local foodlist `foodlist' pastweek_veg i.fpdiet hungry

logit vegchoice i.treat if nonvegdiet == 1 & check1pass == 1 & check2pass == 1, vce(robust)
logit vegchoice i.treat `foodlist' `sdlist' if check1pass == 1 & check2pass == 1, vce(robust)
logit vegchoice i.treat if nonvegdiet == 1, vce(robust)
logit vegchoice i.treat `foodlist' `sdlist' if nonvegdiet == 1, vce(robust)
logistic donchoice i.treat if treat <2, vce(robust)
tobit donchoice i.treat if treat <2, vce(robust) ul(5)
local sdlist `sdlist' age i.gender hhincome i.student i.political
local donlist `donlist' past_donation
churdle linear donation i.treatb1b2, select (i.treatb1b2) ll(0) vce(robust) 
churdle linear donation i.treatb1b2 `donlist' `sdlist', select (i.treatb1b2 `donlist' `sdlist') ll(0) vce(robust)


gen echar = .
replace echar = 1 if chartype == 2
replace echar = 0 if chartype == 1 | chartype == 3
label var echar "Envt Charity"

gen hchar = .
replace hchar = 1 if chartype == 1
replace hchar = 0 if chartype == 2 | chartype == 3
label var hchar "Health Charity"

gen fchar = .
replace fchar = 1 if chartype == 3
replace fchar = 0 if chartype == 1 | chartype == 2
label var fchar "Food Charity"

logit hchar i.treatb1b2, vce(robust) or
logit hchar i.treatb1b2 if nonvegdiet == 1, vce(robust) or

logit echar i.treatb1b2, vce(robust) or
logit echar i.treatb1b2 if nonvegdiet == 1, vce(robust) or

logit fchar i.treatb1b2, vce(robust) or
logit fchar i.treatb1b2 if nonvegdiet == 1, vce(robust) or



local sdlist `sdlist' age i.gender hhincome i.student i.political
local donlist `donlist' past_donation

logistic donchoice i.treatb1b2 if nonvegdiet == 1, vce(robust)
logistic donchoice i.treatb1b2 `donlist' `sdlist' if nonvegdiet == 1, vce(robust)

local sdlist `sdlist' age i.gender hhincome i.student i.political
local donlist `donlist' past_donation

logistic donchoice i.treatb1b2 if vegchoice == 1, vce(robust)
logistic donchoice i.treatb1b2 if vegchoice == 1 & nonvegdiet == 1, vce(robust)


logistic donation i.treatb1b2 `sdlist' `donlist' if vegchoice == 1, vce(robust) or
logistic donation i.treatb1b2 if vegchoice == 1 & nonvegdiet == 1, vce(robust) or

