
clear all
set more off
cd "/Users/anushreedeb/Desktop/MGPS/Data Management/Assignments/Final Paper/Data/DHS India 2015-16/DHS_Birth Recode"
use birth_recode
log using birth_recode.log, replace


gen age = v008 - b3

gen child_age=.
replace child_age = age if child_age==. & b7==.

gen infant_mor=0 if child_age > =12 & child_age!=.
replace infant_mor = 1000 if b7 <12 & b7!=.
replace infant_mor = 0 if b7 > = 12 & b7! =.
label define infant_mor_label 0 Alive 1000 "Died before/on completing 1yr"
label values infant_mor infant_mor_label
tab infant_mor,m

gen child_mor=0 if child_age > = 60 & child_age!=.
replace child_mor = 1000 if b7 <60 & b7!=.
replace child_mor = 0 if b7 > = 60 & b7! =.
label define child_mor_label 0 Alive 1000 "Died before/on completing 5yr"
label values child_mor child_mor_label
tab child_mor,m

rename b4 gender /* sex of child*/
rename v190 wealth_index /* composite index of hh assets */
rename v133 edu /*educational attainment in single years of mother*/
rename v438 height /* height of mother*/

replace v744a = 2 if v744a == 1 /* converted all "yes (1)" responses into 2*/
replace v744b = 2 if v744b == 1
replace v744c = 2 if v744c == 1
replace v744d = 2 if v744d == 1
replace v744e = 2 if v744e == 1
replace s936f = 2 if s936f == 1
replace s936g = 2 if s936g == 1

replace v744a = 1 if v744a == 8 /* converted DKCS (8) responses into 1*/
replace v744b = 1 if v744b == 8
replace v744c = 1 if v744c == 8
replace v744d = 1 if v744d == 8
replace v744e = 1 if v744e == 8
replace s936f = 1 if s936f == 8
replace s936g = 1 if s936g == 8

replace v744a = .5 if v744a == 0 & v744a!=.  /* differentiates between 0 and missing values, converted all no responses to.5 and told STATA that 0/no is not a missing value*/
replace v744b = .5 if v744b == 0 & v744b!=.
replace v744c = .5 if v744c == 0 & v744c!=.
replace v744d = .5 if v744d == 0 & v744d!=.
replace v744e = .5 if v744e == 0 & v744e!=.
replace s936f = .5 if s936f == 0 & s936f!=.
replace s936g = .5 if s936g == 0 & s936g!=.

replace v744a = 0 if v744a ==. /* converted actual missing values to 0*/
replace v744b = 0 if v744b ==.
replace v744c = 0 if v744c ==.
replace v744d = 0 if v744d ==.
replace v744e = 0 if v744e ==.
replace s936f = 0 if s936f ==.
replace s936g = 0 if s936g ==.

egen dom_violence = rsum (v744a v744b v744c v744d v744e s936f s936g)
drop if dom_violence ==0
tab dom_violence /* continuous variable going from low to high */

reg infant_mor dom_violence [pweight = v005] , cluster (v001)
estimates store m1, title(Model 1) 
reg infant_mor dom_violence edu wealth_index height [pweight = v005] , cluster (v001) 
estimates store m2, title(Model 2)
reg infant_mor dom_violence edu wealth_index height i.v025 [pweight = v005] , cluster (v001) 
estimates store m3, title(Model 3)
reg infant_mor dom_violence edu wealth_index height i.v025 if gender == 1 [pweight = v005] , cluster (v001) 
estimates store IMM, title(IMM_DV)
reg infant_mor dom_violence edu wealth_index height i.v025 if gender == 2 [pweight = v005] , cluster (v001)
estimates store IMF, title(IMF_DV)

estout m1 m2 m3 IMM IMF, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

corr infant_mor dom_violence

reg child_mor dom_violence [pweight = v005] , cluster (v001)
estimates store m1, title(Model 1)
reg child_mor dom_violence edu wealth_index height [pweight = v005] , cluster (v001) 
estimates store m2, title(Model 2)
reg child_mor dom_violence edu wealth_index height i.v025 [pweight = v005] , cluster (v001) 
estimates store m3, title(Model 3)
reg child_mor dom_violence edu wealth_index height i.v025 if gender == 1 [pweight = v005] , cluster (v001)
estimates store CMM, title(CMM_DV) 
reg child_mor dom_violence edu wealth_index height i.v025 if gender == 2 [pweight = v005] , cluster (v001)
estimates store CMF, title(CMF_DV) 

estout m1 m2 m3 CMM CMF, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

corr child_mor dom_violence

log close






