*! version 0.3.1 08Nov2017 Mauricio Caceres Bravo, mauricio.caceres.bravo@gmail.com
*! Frequency counts using C-plugins for a speedup.

cap program drop gcontract
program gcontract, rclass
    version 13

    if ( `=_N' == 0 ) {
        di as err "no observations"
        exit 2000
    }

    global GTOOLS_CALLER gcontract
    syntax anything [if] [in], /// [if condition] [in start / end]
    [                          ///
        Freq(string)           /// Name of frequency variable
        CFreq(name)            /// Add cummulative frequency in cfreq
        Percent(name)          /// Add percentages in percent
        CPercent(name)         /// Add cummulative percentages in cpercent
        FLOAT                  /// Store percentages in float variables
        FORMat(string)         /// Format for percentage variables
        Zero                   /// Include varlist combinations with 0 frequency
        noMISS                 /// Exclude rows with missing values in varlist
                               ///
        fast                   /// Do not preserve and restore the original dataset. Saves speed
                               /// but leaves data unusable if the user hits Break.
        unsorted               /// Do not sort the data; faster
                               ///
        Verbose                /// Print info during function execution
        BENCHmark              /// Benchmark function
        BENCHmarklevel(int 0)  /// Benchmark various steps of the plugin
        hashlib(passthru)      /// (Windows only) Custom path to spookyhash.dll
        oncollision(passthru)  /// error|fallback: On collision, use native command or throw error
    ]

    if ( `benchmarklevel' > 0 ) local benchmark benchmark
    local benchmarklevel benchmarklevel(`benchmarklevel')
    local missing = cond("`miss'" == "nomiss", "", "missing")

	* Set type and format for generated numeric variables
	* ---------------------------------------------------

	if ( (`"`percent'"' == "") & (`"`cpercent'"' == "") & (`"`float'"' != "") ) {
		di as error "percent or cpercent must be specified"
		exit 198
	}
	else if ( `"`float'"' == "" ) {
		local numtype "double"
	}
	else {
		local numtype "float"
	}

    if ( `=_N < maxlong()' ) {
        local freqtype long
    }
    else {
        local freqtype double
    }

	if ( (`"`percent'"' == "") & (`"`cpercent'"' == "") & (`"`format'"' != "") ) {
		di as error "percent or cpercent must be specified"
		exit 198
	}
	else  if `"`format'"' == "" {
		local format "%8.2f"
	}

	* Check generated variables
	* -------------------------

	if ( "`zero'" != "" ) {
		capture confirm new variable _fillin
		if ( _rc != 0 ) {
			di as error "_fillin already defined"
			exit 110
		}
	}

	* Parse variable names
	* --------------------

	if ( `"`freq'"' == "" ) {
		capture confirm new variable _freq
		if ( _rc == 0 ) {
			local freq "_freq"
		}
		else {
			di as error "_freq already defined: " ///
			            "use freq() option to specify frequency variable"
			exit 110
		}
	}
	else {
		confirm new variable `freq'
	}

    local types   `freqtype'
    local newvars `freq'
    local cwhich   1

	if ( `"`cfreq'"' != "" ) {
		confirm new variable `cfreq'
        local newvars `newvars' `cfreq'
        local types   `types'   `freqtype'
        local cwhich   `cwhich' 1
	}
    else {
        local cwhich   `cwhich' 0
    }

	if ( `"`percent'"' != "" ) {
		confirm new variable `percent'
        local newvars `newvars' `percent'
        local types   `types'   `numtype'
        local cwhich   `cwhich' 1
	}
    else {
        local cwhich   `cwhich' 0
    }

	if ( `"`cpercent'"' != "" ) {
		confirm new variable `cpercent'
        local newvars `newvars' `cpercent'
        local types   `types'   `numtype'
        local cwhich   `cwhich' 1
	}
    else {
        local cwhich   `cwhich' 0
    }

    * Get varlist
    * -----------

    if ( "`anything'" != "" ) {
        local varlist `anything'
        local varlist: subinstr local varlist "+" "", all
        local varlist: subinstr local varlist "-" "", all
        cap ds `varlist'
        if ( _rc | ("`varlist'" == "") ) {
            local rc = _rc
            di as err "Malformed call: '`anything''"
            di as err "Syntas: [+|-]varname [[+|-]varname ...]"
            exit 111
        }
        local varlist `r(varlist)'
    }

    * Create variables
    * ----------------

    if ( "`fast'" == "" ) preserve
    gtools_timer on 97

    if ( "`if'`in'" != "" ) qui keep `if' `in'

    qui ds *
    local memvars `r(varlist)'
    local dropvars: list memvars - varlist
    if ( "`dropvars'" != "" ) qui mata: st_dropvar(tokens(`"`dropvars'"'))
    qui mata: st_addvar(tokens(`"`types'"'), tokens(`"`newvars'"'))

    local bench = ( "`benchmark'" != "" )
    local msg "Added target variables"
    gtools_timer info 97 `"`msg'"', prints(`bench') off

    * Call the plugin
    * ---------------

    local opts      `missing' `verbose' `benchmark' `benchmarklevel' `hashlib' `oncollision'
    local gcontract gcontract(`newvars', contractwhich(`cwhich'))
    cap noi _gtools_internal `anything', `opts' gfunction(contract) `gcontract'

    local rc = _rc
    global GTOOLS_CALLER ""
    if ( `rc' == 17999 ) {
        if strpos("`anything'", "-") {
            di as err "Cannot use fallback with inverted sorting."
            exit 17000
        }
        else {
            local copts f(`freq') cf(`cfreq') p(`percent') cp(`cpercent') `float' format(`format') `zero' `miss'
            contract `varlist', `copts'
            if ( "`fast'" == "" ) restore, not
            exit 0
        }
    }
    else if ( `rc' == 17001 ) {
        error 2000
    }
    else if ( `rc' ) {
        exit `rc'
    }

    local r_N     = `r(N)'
    local r_J     = `r(J)'
    local r_minJ  = `r(minJ)'
    local r_maxJ  = `r(maxJ)'

    return scalar N    = `r_N'
    return scalar J    = `r_J'
    return scalar minJ = `r_minJ'
    return scalar maxJ = `r_maxJ'

    * Exit in the style of contract
    * -----------------------------

    qui keep in 1 / `:di %21.0g `r_J''
	if ( "`zero'" != "" ) {
		qui fillin `varlist'
		qui replace `freq' = 0 if `freq' >= .
		qui drop _fillin
        cap confirm var `percent'
        if ( _rc == 0 ) {
            qui replace `percent' = 0 if `percent' >= .
        }
        if ( "`cpercent'`cfreq'" != "" ) {
            foreach var of varlist `cfreq' `cpercent' {
                qui replace `var' = 0 in 1  if `var'[1] >= .
                if ( `=_N' > 1 ) {
                    qui replace `var' = `var'[_n - 1] in 2 / `=_N' if `var' >= .
                }
            }
        }
	}

	qui compress `freq' `cfreq' `percent' `cpercent'

    if ( "`percent'`cpercent'" != "" ) {
        format `format' `percent' `cpercent'
    }

    if ( "`fast'" == "" ) restore, not
end


***********************************************************************
*                           Generic helpers                           *
***********************************************************************

capture program drop gtools_timer
program gtools_timer, rclass
    syntax anything, [prints(int 0) end off]
    tokenize `"`anything'"'
    local what  `1'
    local timer `2'
    local msg   `"`3'; "'

    if ( inlist("`what'", "start", "on") ) {
        cap timer off `timer'
        cap timer clear `timer'
        timer on `timer'
    }
    else if ( inlist("`what'", "info") ) {
        timer off `timer'
        qui timer list
        return scalar t`timer' = `r(t`timer')'
        return local pretty`timer' = trim("`:di %21.4gc r(t`timer')'")
        if ( `prints' ) di `"`msg'`:di trim("`:di %21.4gc r(t`timer')'")' seconds"'
        timer off `timer'
        timer clear `timer'
        timer on `timer'
    }

    if ( "`end'`off'" != "" ) {
        timer off `timer'
        timer clear `timer'
    }
end
