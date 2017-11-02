* ---------------------------------------------------------------------
* Project: gtools
* Program: gtools_tests.do
* Author:  Mauricio Caceres Bravo <mauricio.caceres.bravo@gmail.com>
* Created: Tue May 16 07:23:02 EDT 2017
* Updated: Wed Nov  1 07:16:28 EDT 2017
* Purpose: Unit tests for gtools
* Version: 0.9.3
* Manual:  help gtools

* Stata start-up options
* ----------------------

version 13
clear all
set more off
set varabbrev off
set seed 1729
set linesize 255

* Main program wrapper
* --------------------

program main
    syntax, [NOIsily *]

    if ( inlist("`c(os)'", "MacOSX") | strpos("`c(machine_type)'", "Mac") ) {
        local c_os_ macosx
    }
    else {
        local c_os_: di lower("`c(os)'")
    }
    log using gtools_tests_`c_os_'.log, text replace name(gtools_tests)

    * Set up
    * ------

    local  progname tests
    local  start_time "$S_TIME $S_DATE"

    di _n(1)
    di "Start:        `start_time'"
    di "Options:      `options'"
    di "OS:           `c(os)'"
    di "Machine Type: `c(machine_type)'"

    * Run the things
    * --------------

    cap noi {
        * qui do test_gcollapse.do
        * qui do test_gcontract.do
        * qui do test_gegen.do
        * qui do test_gisid.do
        * qui do test_glevelsof.do
        * qui do test_gtoplevelsof.do
        * qui do test_gunique.do
        * qui do test_hashsort.do

        if ( `:list posof "dependencies" in options' ) {
            cap ssc install ralpha
            cap ssc install ftools
            cap ssc install unique
            cap ssc install distinct
            cap ssc install moremata
        }

        if ( `:list posof "basic_checks" in options' ) {

            di _n(1)

            unit_test, `noisily' test(checks_corners, `noisily' oncollision(error))

            di ""
            di "-------------------------------------"
            di "Basic unit-tests $S_TIME $S_DATE"
            di "-------------------------------------"

            unit_test, `noisily' test(checks_gcollapse,   `noisily' oncollision(error))
            unit_test, `noisily' test(checks_gcontract,   `noisily' oncollision(error))
            unit_test, `noisily' test(checks_gegen,       `noisily' oncollision(error))
            unit_test, `noisily' test(checks_isid,        `noisily' oncollision(error))
            unit_test, `noisily' test(checks_levelsof,    `noisily' oncollision(error))
            unit_test, `noisily' test(checks_toplevelsof, `noisily' oncollision(error))
            unit_test, `noisily' test(checks_unique,      `noisily' oncollision(error))
            unit_test, `noisily' test(checks_hashsort,    `noisily' oncollision(error))
        }

        if ( `:list posof "comparisons" in options' ) {

            di ""
            di "-----------------------------------------------------------"
            di "Consistency checks (v native commands) $S_TIME $S_DATE"
            di "-----------------------------------------------------------"

            compare_gcollapse,   `noisily' oncollision(error) tol(1e-4)
            compare_gcontract,   `noisily' oncollision(error)
            compare_egen,        `noisily' oncollision(error)
            compare_isid,        `noisily' oncollision(error)
            compare_levelsof,    `noisily' oncollision(error)
            compare_toplevelsof, `noisily' oncollision(error) tol(1e-4)
            compare_unique,      `noisily' oncollision(error) distinct
            compare_hashsort,    `noisily' oncollision(error)
        }

        if ( `:list posof "bench_test" in options' ) {
            bench_collapse, collapse fcollapse bench(10)  n(100)    style(sum)    vars(15) oncollision(error)
            bench_collapse, collapse fcollapse bench(10)  n(100)    style(ftools) vars(6)  oncollision(error)
            bench_collapse, collapse fcollapse bench(10)  n(100)    style(full)   vars(1)  oncollision(error)

            bench_collapse, collapse fcollapse bench(0.05) n(10000) style(sum)    vars(15) oncollision(error)
            bench_collapse, collapse fcollapse bench(0.05) n(10000) style(ftools) vars(6)  oncollision(error)
            bench_collapse, collapse fcollapse bench(0.05) n(10000) style(full)   vars(1)  oncollision(error)

            bench_contract,    n(1000) bench(1) `noisily' oncollision(error)
            bench_egen,        n(1000) bench(1) `noisily' oncollision(error)
            bench_isid,        n(1000) bench(1) `noisily' oncollision(error)
            bench_levelsof,    n(100)  bench(1) `noisily' oncollision(error)
            bench_toplevelsof, n(1000) bench(1) `noisily' oncollision(error)
            bench_unique,      n(1000) bench(1) `noisily' oncollision(error)
            bench_unique,      n(1000) bench(1) `noisily' oncollision(error) distinct
            * bench_unique,      n(1000) bench(1) `noisily' oncollision(error) distinct joint distunique
            bench_hashsort,    n(1000) bench(1) `noisily' oncollision(error) benchmode
        }

        if ( `:list posof "bench_full" in options' ) {
            bench_collapse, collapse fcollapse bench(1000) n(100)    style(sum)    vars(15) oncollision(error)
            bench_collapse, collapse fcollapse bench(1000) n(100)    style(ftools) vars(6)  oncollision(error)
            bench_collapse, collapse fcollapse bench(1000) n(100)    style(full)   vars(1)  oncollision(error)

            bench_collapse, collapse fcollapse bench(0.1)  n(1000000) style(sum)    vars(15) oncollision(error)
            bench_collapse, collapse fcollapse bench(0.1)  n(1000000) style(ftools) vars(6)  oncollision(error)
            bench_collapse, collapse fcollapse bench(0.1)  n(1000000) style(full)   vars(1)  oncollision(error)

            bench_contract,    n(10000) bench(10)  `noisily' oncollision(error)
            bench_egen,        n(10000) bench(10)  `noisily' oncollision(error)
            bench_isid,        n(10000) bench(10)  `noisily' oncollision(error)
            bench_levelsof,    n(100)   bench(100) `noisily' oncollision(error)
            bench_toplevelsof, n(10000) bench(10) `noisily' oncollision(error)
            bench_unique,      n(10000) bench(10)  `noisily' oncollision(error)
            bench_unique,      n(10000) bench(10)  `noisily' oncollision(error) distinct
            * bench_unique,      n(10000) bench(10)  `noisily' oncollision(error) distinct joint distunique
            bench_hashsort,    n(10000) bench(10)  `noisily' oncollision(error) benchmode
        }
    }
    local rc = _rc

    exit_message, rc(`rc') progname(`progname') start_time(`start_time') `capture'
    log close gtools_tests
    exit `rc'
end

* ---------------------------------------------------------------------
* Aux programs

capture program drop exit_message
program exit_message
    syntax, rc(int) progname(str) start_time(str) [CAPture]
    local end_time "$S_TIME $S_DATE"
    local time     "Start: `start_time'" _n(1) "End: `end_time'"
    di ""
    if (`rc' == 0) {
        di "End: $S_TIME $S_DATE"
        local paux      ran
        local message "`progname' finished running" _n(2) "`time'"
        local subject "`progname' `paux'"
    }
    else if ("`capture'" == "") {
        di "WARNING: $S_TIME $S_DATE"
        local paux ran with non-0 exit status
        local message "`progname' ran but Stata gave error code r(`rc')" _n(2) "`time'"
        local subject "`progname' `paux'"
    }
    else {
        di "ERROR: $S_TIME $S_DATE"
        local paux ran with errors
        local message "`progname' stopped with error code r(`rc')" _n(2) "`time'"
        local subject "`progname' `paux'"
    }
    di "`subject'"
    di ""
    di "`message'"
end

* Wrapper for easy timer use
cap program drop mytimer
program mytimer, rclass
    * args number what step
    syntax anything, [minutes ts]

    tokenize `anything'
    local number `1'
    local what   `2'
    local step   `3'

    if ("`what'" == "end") {
        qui {
            timer clear `number'
            timer off   `number'
        }
        if ("`ts'" == "ts") mytimer_ts `step'
    }
    else if ("`what'" == "info") {
        qui {
            timer off `number'
            timer list `number'
        }
        local seconds = r(t`number')
        local prints  `:di trim("`:di %21.2gc `seconds''")' seconds
        if ("`minutes'" != "") {
            local minutes = `seconds' / 60
            local prints  `:di trim("`:di %21.3gc `minutes''")' minutes
        }
        mytimer_ts Step `step' took `prints'
        qui {
            timer clear `number'
            timer on    `number'
        }
    }
    else {
        qui {
            timer clear `number'
            timer on    `number'
            timer off   `number'
            timer list  `number'
            timer on    `number'
        }
        if ("`ts'" == "ts") mytimer_ts `step'
    }
end

capture program drop mytimer_ts
program mytimer_ts
    display _n(1) "{hline 79}"
    if ("`0'" != "") display `"`0'"'
    display `"        Base: $S_FN"'
    display  "        In memory: `:di trim("`:di %21.0gc _N'")' observations"
    display  "        Timestamp: $S_TIME $S_DATE"
    display  "{hline 79}" _n(1)
end

capture program drop unit_test
program unit_test
    syntax, test(str) [NOIsily tab(int 4)]
    local tabs `""'
    forvalues i = 1 / `tab' {
        local tabs "`tabs' "
    }
    cap `noisily' `test'
    if ( _rc ) {
        di as error `"`tabs'test(failed): `test'"'
        exit _rc
    }
    else di as txt `"`tabs'test(passed): `test'"'
end

capture program drop gen_data
program gen_data
    syntax, [n(int 100) random(int 0) binary(int 0) double]
    clear
    set obs `n'

    * Random strings
    * --------------

    qui ralpha str_long,  l(5)
    qui ralpha str_mid,   l(3)
    qui ralpha str_short, l(1)

    * Generate does-what-it-says-on-the-tin variables
    * -----------------------------------------------

    gen str32 str_32   = str_long + "this is some string padding"
    gen str12 str_12   = str_mid  + "padding" + str_short + str_short
    gen str4  str_4    = str_mid  + str_short

    gen long   int1  = floor(uniform() * 1000)
    gen long   int2  = floor(rnormal())
    gen double int3  = floor(rnormal() * 5 + 10)

    gen double double1 = uniform() * 1000
    gen double double2 = rnormal()
    gen double double3 = rnormal() * 5 + 10

    * Mix up string lengths
    * ---------------------

   replace str_32 = str_mid + str_short if mod(_n, 4) == 0
   replace str_12 = str_short + str_mid if mod(_n, 4) == 2

    * Insert some blanks
    * ------------------

    replace str_32 = "            " in 1 / 10
    replace str_12 = "   "          in 1 / 10
    replace str_4  = " "            in 1 / 10

    replace str_32 = "            " if mod(_n, 21) == 0
    replace str_12 = "   "          if mod(_n, 34) == 0
    replace str_4  = " "            if mod(_n, 55) == 0

    * Missing values
    * --------------

    replace str_32 = "" if mod(_n, 10) ==  0
    replace str_12 = "" if mod(_n, 20) ==  0
    replace str_4  = "" if mod(_n, 20) == 10

    replace int2  = .   if mod(_n, 10) ==  0
    replace int3  = .a  if mod(_n, 20) ==  0
    replace int3  = .f  if mod(_n, 20) == 10

    replace double2 = .   if mod(_n, 10) ==  0
    replace double3 = .h  if mod(_n, 20) ==  0
    replace double3 = .p  if mod(_n, 20) == 10

    * Singleton groups
    * ----------------

    replace str_32 = "|singleton|" in `n'
    replace str_12 = "|singleton|" in `n'
    replace str_4  = "|singleton|" in `n'

    replace int1    = 99999  in `n'
    replace double1 = 9999.9 in `n'

    replace int3 = .  in 1
    replace int3 = .a in 2
    replace int3 = .b in 3
    replace int3 = .c in 4
    replace int3 = .d in 5
    replace int3 = .e in 6
    replace int3 = .f in 7
    replace int3 = .g in 8
    replace int3 = .h in 9
    replace int3 = .i in 10
    replace int3 = .j in 11
    replace int3 = .k in 12
    replace int3 = .l in 13
    replace int3 = .m in 14
    replace int3 = .n in 15
    replace int3 = .o in 16
    replace int3 = .p in 17
    replace int3 = .q in 18
    replace int3 = .r in 19
    replace int3 = .s in 20
    replace int3 = .t in 21
    replace int3 = .u in 22
    replace int3 = .v in 23
    replace int3 = .w in 24
    replace int3 = .x in 25
    replace int3 = .y in 26
    replace int3 = .z in 27

    replace double3 = .  in 1
    replace double3 = .a in 2
    replace double3 = .b in 3
    replace double3 = .c in 4
    replace double3 = .d in 5
    replace double3 = .e in 6
    replace double3 = .f in 7
    replace double3 = .g in 8
    replace double3 = .h in 9
    replace double3 = .i in 10
    replace double3 = .j in 11
    replace double3 = .k in 12
    replace double3 = .l in 13
    replace double3 = .m in 14
    replace double3 = .n in 15
    replace double3 = .o in 16
    replace double3 = .p in 17
    replace double3 = .q in 18
    replace double3 = .r in 19
    replace double3 = .s in 20
    replace double3 = .t in 21
    replace double3 = .u in 22
    replace double3 = .v in 23
    replace double3 = .w in 24
    replace double3 = .x in 25
    replace double3 = .y in 26
    replace double3 = .z in 27

    if ( `random' > 0 ) {
        forvalues i = 1 / `random' {
            gen `double' random`i' = rnormal() * 10
            replace random`i' = . if mod(_n, 20) == 0
            if ( `binary' ) {
                replace random`i' = floor(runiform() * 1.99) if _n < `=_N / 2'
            }
        }
    }
end

capture program drop checks_gcollapse
program checks_gcollapse
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_gcollapse, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(5000) random(2)
    qui expand 2
    gen long ix = _n

    checks_inner_collapse, `options'

    checks_inner_collapse -str_12,              `options'
    checks_inner_collapse str_12 -str_32,       `options'
    checks_inner_collapse str_12 -str_32 str_4, `options'

    checks_inner_collapse -double1,                 `options'
    checks_inner_collapse double1 -double2,         `options'
    checks_inner_collapse double1 -double2 double3, `options'

    checks_inner_collapse -int1,           `options'
    checks_inner_collapse int1 -int2,      `options'
    checks_inner_collapse int1 -int2 int3, `options'

    checks_inner_collapse -int1 -str_32 -double1,                                         `options'
    checks_inner_collapse int1 -str_32 double1 -int2 str_12 -double2,                     `options'
    checks_inner_collapse int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options'
end

capture program drop checks_inner_collapse
program checks_inner_collapse
    syntax [anything], [tol(real 1e-6) *]

    local stats sum mean sd max min count median iqr percent first last firstnm lastnm semean sebinomial sepoisson
    local percentiles p1 p10 p30.5 p50 p70.5 p90 p99

    local collapse_str ""
    foreach stat of local stats {
        local collapse_str `collapse_str' (`stat') r1_`stat' = random1
        local collapse_str `collapse_str' (`stat') r2_`stat' = random2
    }
    foreach pct of local percentiles {
        local collapse_str `collapse_str' (`pct') r1_`:subinstr local pct "." "_", all' = random1
        local collapse_str `collapse_str' (`pct') r2_`:subinstr local pct "." "_", all' = random2
    }

    preserve
        gcollapse `collapse_str', by(`anything') verbose `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') verbose benchmark `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') verbose forceio `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') verbose forcemem `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') verbose benchmark cw `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') verbose benchmark fast `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') double `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') merge `options'
    restore, preserve
        gcollapse `collapse_str', by(`anything') verbose `options' benchmark debug_io_check(0)
    restore
end

***********************************************************************
*                            Corner cases                             *
***********************************************************************

capture program drop checks_corners
program checks_corners
    syntax, [*]
    di _n(1) "{hline 80}" _n(1) "checks_corners `options'" _n(1) "{hline 80}" _n(1)

    qui {
        sysuse auto, clear
        gen price2 = price
        cap noi gcollapse price = price2 if price < 0
        assert _rc == 2000
    }

    qui {
        sysuse auto, clear
        gen price2 = price
        gcollapse price = price2
    }

    qui {
        sysuse auto, clear
        gen price2 = price
        gcollapse price = price2, by(make) v bench `options'
        gcollapse price in 1,     by(make) v bench `options'
    }

    qui {
        clear
        set matsize 100
        set obs 10
        forvalues i = 1/101 {
            gen x`i' = 10
        }
        gen zz = runiform()
        preserve
            gcollapse zz, by(x*) `options'
        restore, preserve
            gcollapse x*, by(zz) `options'
        restore
    }

    qui {
        clear
        set matsize 400
        set obs 10
        forvalues i = 1/300 {
            gen x`i' = 10
        }
        gen zz = runiform()
        preserve
            gcollapse zz, by(x*) `options'
        restore, preserve
            gcollapse x*, by(zz) `options'
        restore
    }

    qui {
        clear
        set obs 10
        forvalues i = 1/800 {
            gen x`i' = 10
        }
        gen zz = runiform()
        preserve
            gcollapse zz, by(x*) `options'
        restore, preserve
            gcollapse x*, by(zz) `options'
        restore

        * Only fails in Stata/IC
        * gen x801 = 10
        * preserve
        *     collapse zz, by(x*) `options'
        * restore, preserve
        *     collapse x*, by(zz) `options'
        * restore
    }

    di ""
    di as txt "Passed! checks_corners `options'"
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_gcollapse
program compare_gcollapse
    syntax, [tol(real 1e-6) NOIsily *]

    * This should be ignored for compare_inner_gcollapse_gegen bc of merge
    local debug_io debug_io_check(0) debug_io_threshold(0.0001)

    qui `noisily' gen_data, n(1000) random(2)
    qui expand 100

    di _n(1) "{hline 80}" _n(1) "consistency_gcollapse_gegen, `options'" _n(1) "{hline 80}" _n(1)

    compare_inner_gcollapse_gegen, `options' tol(`tol')

    compare_inner_gcollapse_gegen -str_12,              `options' tol(`tol') `debug_io'
    compare_inner_gcollapse_gegen str_12 -str_32,       `options' tol(`tol') sort
    compare_inner_gcollapse_gegen str_12 -str_32 str_4, `options' tol(`tol') shuffle

    compare_inner_gcollapse_gegen -double1,                 `options' tol(`tol') `debug_io'
    compare_inner_gcollapse_gegen double1 -double2,         `options' tol(`tol') sort
    compare_inner_gcollapse_gegen double1 -double2 double3, `options' tol(`tol') shuffle

    compare_inner_gcollapse_gegen -int1,           `options' tol(`tol') `debug_io'
    compare_inner_gcollapse_gegen int1 -int2,      `options' tol(`tol') sort
    compare_inner_gcollapse_gegen int1 -int2 int3, `options' tol(`tol') shuffle

    compare_inner_gcollapse_gegen -int1 -str_32 -double1, `options' tol(`tol') `debug_io'
    compare_inner_gcollapse_gegen int1 -str_32 double1 -int2 str_12 -double2, `options' tol(`tol') sort
    compare_inner_gcollapse_gegen int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options' tol(`tol') shuffle

    qui `noisily' gen_data, n(1000) random(2) binary(1)
    qui expand 50

    di _n(1) "{hline 80}" _n(1) "consistency_collapse, `options'" _n(1) "{hline 80}" _n(1)

    compare_inner_collapse, `options' tol(`tol')

    compare_inner_collapse str_12,              `options' tol(`tol') forcemem sort
    compare_inner_collapse str_12 str_32,       `options' tol(`tol') forceio shuffle
    compare_inner_collapse str_12 str_32 str_4, `options' tol(`tol') `debug_io'

    compare_inner_collapse double1,                 `options' tol(`tol') forcemem
    compare_inner_collapse double1 double2,         `options' tol(`tol') forceio sort
    compare_inner_collapse double1 double2 double3, `options' tol(`tol') `debug_io' shuffle

    compare_inner_collapse int1,           `options' tol(`tol') forcemem shuffle
    compare_inner_collapse int1 int2,      `options' tol(`tol') forceio
    compare_inner_collapse int1 int2 int3, `options' tol(`tol') `debug_io' sort

    compare_inner_collapse int1 str_32 double1,                                        `options' tol(`tol') forcemem
    compare_inner_collapse int1 str_32 double1 int2 str_12 double2,                    `options' tol(`tol') forceio
    compare_inner_collapse int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options' tol(`tol') `debug_io'
end

capture program drop compare_inner_gcollapse_gegen
program compare_inner_gcollapse_gegen
    syntax [anything], [tol(real 1e-6) sort shuffle *]

    tempvar rsort
    if ( "`shuffle'" != "" ) gen `rsort' = runiform()
    if ( "`shuffle'" != "" ) sort `rsort'
    if ( ("`sort'" != "") & ("`anything'" != "") ) hashsort `anything'

    local N = trim("`: di %15.0gc _N'")
    local hlen = 45 + length("`anything'") + length("`N'")
    di _n(2) "Checking gegen vs gcollapse. N = `N'; varlist = `anything'" _n(1) "{hline `hlen'}"

    preserve
        _compare_inner_gcollapse_gegen `anything', `options' tol(`tol')
    restore, preserve
        if ( "`shuffle'" != "" ) sort `rsort'
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_gcollapse_gegen  `anything' in `from' / `to', `options' tol(`tol')
    restore, preserve
        _compare_inner_gcollapse_gegen `anything' if random2 > 0, `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_gcollapse_gegen `anything' if random2 < 0 in `from' / `to', `options' tol(`tol')
    restore
end

capture program drop _compare_inner_gcollapse_gegen
program _compare_inner_gcollapse_gegen
    syntax [anything] [if] [in], [tol(real 1e-6) *]

    gegen id = group(`anything'), missing

    gegen double mean       = mean       (random1) `if' `in',  by(`anything')
    gegen double sum        = sum        (random1) `if' `in',  by(`anything')
    gegen double median     = median     (random1) `if' `in',  by(`anything')
    gegen double sd         = sd         (random1) `if' `in',  by(`anything')
    gegen double iqr        = iqr        (random1) `if' `in',  by(`anything')
    gegen double first      = first      (random1) `if' `in',  by(`anything')
    gegen double last       = last       (random1) `if' `in',  by(`anything')
    gegen double firstnm    = firstnm    (random1) `if' `in',  by(`anything')
    gegen double lastnm     = lastnm     (random1) `if' `in',  by(`anything')
    gegen double semean     = semean     (random1) `if' `in',  by(`anything')
    gegen double sebinomial = sebinomial (random1) `if' `in',  by(`anything')
    gegen double sepoisson  = sepoisson  (random1) `if' `in',  by(`anything')
    gegen double q10        = pctile     (random1) `if' `in',  by(`anything') p(10.5)
    gegen double q30        = pctile     (random1) `if' `in',  by(`anything') p(30)
    gegen double q70        = pctile     (random1) `if' `in',  by(`anything') p(70)
    gegen double q90        = pctile     (random1) `if' `in',  by(`anything') p(90.5)

    qui `noisily' {
        gcollapse (mean)       g_mean       = random1  ///
                  (sum)        g_sum        = random1  ///
                  (median)     g_median     = random1  ///
                  (sd)         g_sd         = random1  ///
                  (iqr)        g_iqr        = random1  ///
                  (first)      g_first      = random1  ///
                  (last)       g_last       = random1  ///
                  (firstnm)    g_firstnm    = random1  ///
                  (lastnm)     g_lastnm     = random1  ///
                  (semean)     g_semean     = random1  ///
                  (sebinomial) g_sebinomial = random1  ///
                  (sepoisson)  g_sepoisson  = random1  ///
                  (p10.5)      g_q10        = random1  ///
                  (p30)        g_q30        = random1  ///
                  (p70)        g_q70        = random1  ///
                  (p90.5)      g_q90        = random1 `if' `in', by(id) benchmark verbose `options' merge double
    }

    if ( "`if'`in'" == "" ) {
        di _n(1) "Checking full range: `anything'"
    }
    else if ( "`if'`in'" != "" ) {
        di _n(1) "Checking [`if' `in'] range: `anything'"
    }

    foreach fun in mean sum median sd iqr first last firstnm lastnm semean sebinomial sepoisson q10 q30 q70 q90 {
        cap noi assert (g_`fun' == `fun') | abs(g_`fun' - `fun') < `tol'
        if ( _rc ) {
            recast double g_`fun' `fun'
            cap noi assert (g_`fun' == `fun') | abs(g_`fun' - `fun') < `tol'
            if ( _rc ) {
                di as err "    compare_gegen_gcollapse (failed): `fun' yielded different results (tol = `tol')"
                exit _rc
            }
            else di as txt "    compare_gegen_gcollapse (passed): `fun' yielded same results (tol = `tol')"
        }
        else di as txt "    compare_gegen_gcollapse (passed): `fun' yielded same results (tol = `tol')"
    }
end

capture program drop compare_inner_collapse
program compare_inner_collapse
    syntax [anything], [tol(real 1e-6) sort shuffle *]

    tempvar rsort
    if ( "`shuffle'" != "" ) gen `rsort' = runiform()
    if ( "`shuffle'" != "" ) sort `rsort'
    if ( ("`sort'" != "") & ("`anything'" != "") ) hashsort `anything'

    local N = trim("`: di %15.0gc _N'")
    local hlen = 35 + length("`anything'") + length("`N'")
    di _n(2) "Checking collapse. N = `N'; varlist = `anything'" _n(1) "{hline `hlen'}"

    preserve
        _compare_inner_collapse `anything', `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_collapse  `anything' in `from' / `to', `options' tol(`tol')
    restore, preserve
        _compare_inner_collapse `anything' if random2 > 0, `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_collapse `anything' if random2 < 0 in `from' / `to', `options' tol(`tol')
    restore
end

capture program drop _compare_inner_collapse
program _compare_inner_collapse
    syntax [anything] [if] [in], [tol(real 1e-6) *]

    local stats sum mean sd max min count percent first last firstnm lastnm median iqr semean sebinomial sepoisson
    local percentiles p1 p13 p30 p50 p70 p87 p99
    local collapse_str ""
    foreach stat of local stats {
        local collapse_str `collapse_str' (`stat') r1_`stat' = random1
        local collapse_str `collapse_str' (`stat') r2_`stat' = random2
    }
    foreach pct of local percentiles {
        local collapse_str `collapse_str' (`pct') r1_`pct' = random1
        local collapse_str `collapse_str' (`pct') r2_`pct' = random2
    }

    preserve
        timer clear
        timer on 43
        qui `noisily' gcollapse `collapse_str' `if' `in', by(`anything') verbose benchmark `options' freq(freq)
        timer off 43
        qui timer list
        local time_gcollapse = r(t43)
        tempfile fg
        qui save `fg'
    restore

    preserve
        timer clear
        timer on 42
        qui gen long freq = 1
        qui `noisily' collapse `collapse_str' (sum) freq `if' `in', by(`anything')
        timer off 42
        qui timer list
        local time_gcollapse = r(t42)
        tempfile fc
        qui save `fc'
    restore

    preserve
    use `fc', clear
        local bad_any = 0
        local bad `anything'
        local by  `anything'
        foreach var in `stats' `percentiles' {
            rename r1_`var' c_r1_`var'
            rename r2_`var' c_r2_`var'
        }
        rename freq c_freq
        if ( "`by'" == "" ) {
            qui merge 1:1 _n using `fg', assert(3)
        }
        else {
            qui merge 1:1 `by' using `fg', assert(3)
        }
        foreach var in `stats' `percentiles' {
            qui count if ( (abs(r1_`var' - c_r1_`var') > `tol') & (r1_`var' != c_r1_`var'))
            if ( `r(N)' > 0 ) {
                gen bad_r1_`var' = abs(r1_`var' - c_r1_`var') * (r1_`var' != c_r1_`var')
                local bad `bad' *r1_`var'
                di "    r1_`var' has `:di r(N)' mismatches".
                local bad_any = 1
                order *r1_`var'
            }

            qui count if ( (abs(r2_`var' - c_r2_`var') > `tol') & (r2_`var' != c_r2_`var'))
            if ( `r(N)' > 0 ) {
                gen bad_r2_`var' = abs(r2_`var' - c_r2_`var') * (r2_`var' != c_r2_`var')
                local bad `bad' *r2_`var'
                di "    r2_`var' has `:di r(N)' mismatches".
                local bad_any = 1
                order *r2_`var'
            }
        }
        qui count if ( (abs(freq - c_freq) > `tol') & (freq != c_freq))
        if ( `r(N)' > 0 ) {
            gen bad_freq = abs(freq - c_freq) * (freq != c_freq)
            local bad `bad' *freq
            di "    freq has `:di r(n)' mismatches".
            local bad_any = 1
            order *freq
        }
        if ( `bad_any' ) {
            if ( "`if'`in'" == "" ) {
                di "    compare_collapse (failed): full range, `anything'"
            }
            else if ( "`if'`in'" != "" ) {
                di "    compare_collapse (failed): [`if' `in'], `anything'"
            }
            order `bad'
            egen bad_any = rowmax(bad_*)
            l *count* *mean* `bad' if bad_any
            sum bad_*
            desc
            exit 9
        }
        else {
            if ( "`if'`in'" == "" ) {
                di "    compare_collapse (passed): full range, gcollapse results equal to collapse (tol = `tol')"
            }
            else if ( "`if'`in'" != "" ) {
                di "    compare_collapse (passed): [`if' `in'], gcollapse results equal to collapse (tol = `tol')"
            }
        }
    restore
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_collapse
program bench_collapse
    syntax, [tol(real 1e-6) bench(real 1) n(int 1000) NOIsily style(str) vars(int 1) collapse fcollapse *]

    qui gen_data, n(`n') random(`vars') double
    qui expand `=100 * `bench''
    qui hashsort random1

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    if ( "`style'" == "full" ) {
        local ststr "all available plus percentiles 10, 30, 70, 90"
    }
    else if ( "`style'" == "ftools" ) {
        local ststr "mean median min max"
    }
    else {
        local ststr "sum"
    }

    if ( `vars' > 1 ) {
        local vstr "x1-x`vars'"
    }
    else {
        local vstr x1
    }

    di as txt _n(1)
    di as txt "Benchmark vs collapse (in seconds)"
    di as txt "    - obs:     `N'"
    di as txt "    - groups:  `J'"
    di as txt "    - vars:    `vstr' ~ N(0, 10)"
    di as txt "    - stats:   `ststr'"
    di as txt "    - options: fast"
    di as txt _n(1)
    di as txt "    collapse | fcollapse | gcollapse | ratio (c/g) | ratio (f/g) | varlist"
    di as txt "    -------- | --------- | --------- | ----------- | ----------- | -------"

    local options `options' style(`style') vars(`vars')
    versus_collapse,                         `options' `collapse' `fcollapse'
    versus_collapse str_12 str_32 str_4,     `options' `collapse' `fcollapse'
    versus_collapse double1 double2 double3, `options' `collapse' `fcollapse'
    versus_collapse int1 int2,               `options' `collapse' `fcollapse'
    versus_collapse int3 str_32 double1,     `options' `collapse'

    di _n(1) "{hline 80}" _n(1) "bench_collapse, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_collapse
program versus_collapse, rclass
    syntax [anything], [fcollapse collapse style(str) vars(int 1) *]

    local stats       ""
    local percentiles ""

    if ( "`style'" == "full" ) {
        local stats sum mean sd max min count median iqr percent first last firstnm lastnm
        local percentiles p10 p30 p70 p90
    }
    else if ( "`style'" == "ftools" ) {
        local stats mean median min max
    }
    else {
        local stats sum
    }

    local collapse_str ""
    foreach stat of local stats {
        forvalues k = 1 / `vars' {
            local collapse_str `collapse_str' (`stat') r`k'_`stat' = random`k'
        }
    }
    foreach pct of local percentiles {
        forvalues k = 1 / `vars' {
            local collapse_str `collapse_str' (`pct') r`k'_`pct' = random`k'
        }
    }

    if ( "`collapse'" == "collapse" ) {
    preserve
        timer clear
        timer on 42
        qui collapse `collapse_str', by(`anything') fast
        timer off 42
        qui timer list
        local time_collapse = r(t42)
    restore
    }
    else {
        local time_collapse = .
    }

    preserve
        timer clear
        timer on 43
        qui gcollapse `collapse_str', by(`anything') `options' fast
        timer off 43
        qui timer list
        local time_gcollapse = r(t43)
    restore

    if ( "`fcollapse'" == "fcollapse" ) {
    preserve
        timer clear
        timer on 44
        qui fcollapse `collapse_str', by(`anything') fast
        timer off 44
        qui timer list
        local time_fcollapse = r(t44)
    restore
    }
    else {
        local time_fcollapse = .
    }

    local rs = `time_collapse'  / `time_gcollapse'
    local rf = `time_fcollapse' / `time_gcollapse'
    di as txt "    `:di %8.3g `time_collapse'' | `:di %9.3g `time_fcollapse'' | `:di %9.3g `time_gcollapse'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `anything'"
end
capture program drop checks_gcontract
program checks_gcontract
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_gcontract, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(5000) random(2)
    qui expand 2
    gen long ix = _n

    cap gcontract
    assert _rc == 100

    checks_inner_contract -str_12,              `options' nomiss
    checks_inner_contract str_12 -str_32,       `options'
    checks_inner_contract str_12 -str_32 str_4, `options'

    checks_inner_contract -double1,                 `options' fast
    checks_inner_contract double1 -double2,         `options' unsorted
    checks_inner_contract double1 -double2 double3, `options' v bench

    checks_inner_contract -int1,           `options'
    checks_inner_contract int1 -int2,      `options'
    checks_inner_contract int1 int2  int3, `options' z

    checks_inner_contract -int1 -str_32 -double1,                                         `options'
    checks_inner_contract int1 -str_32 double1 -int2 str_12 -double2,                     `options'
    checks_inner_contract int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options'
end

capture program drop checks_inner_contract
program checks_inner_contract
    syntax [anything], [tol(real 1e-6) *]

    preserve
        gcontract `anything', `options' freq(freq)
    restore, preserve
        gcontract `anything', `options' freq(freq) cf(cf)
    restore, preserve
        gcontract `anything', `options' freq(freq)        p(p)        format(%5.1g)
    restore, preserve
        gcontract `anything', `options' freq(freq)             cp(cp) float
    restore, preserve
        gcontract `anything', `options' freq(freq) cf(cf) p(p)        float
    restore, preserve
        gcontract `anything', `options' freq(freq) cf(cf)      cp(cp) format(%5.1g)
    restore, preserve
        gcontract `anything', `options' freq(freq)        p(p) cp(cp) format(%5.1g)
    restore, preserve
        gcontract `anything', `options' freq(freq) cf(cf) p(p) cp(cp) float
    restore
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_gcontract
program compare_gcontract
    syntax, [tol(real 1e-6) NOIsily *]

    qui `noisily' gen_data, n(1000) random(2) binary(1)
    qui expand 50

    di as txt _n(1) "{hline 80}" _n(1) "consistency_gtoplevelsof_gcontract, `options'" _n(1) "{hline 80}" _n(1)

    compare_inner_contract str_12,              `options' tol(`tol') nomiss
    compare_inner_contract str_12 str_32,       `options' tol(`tol') sort
    compare_inner_contract str_12 str_32 str_4, `options' tol(`tol') shuffle

    compare_inner_contract double1,                 `options' tol(`tol') shuffle
    compare_inner_contract double1 double2,         `options' tol(`tol') nomiss
    compare_inner_contract double1 double2 double3, `options' tol(`tol') sort

    compare_inner_contract int1,           `options' tol(`tol') sort
    compare_inner_contract int1 int2,      `options' tol(`tol') shuffle
    compare_inner_contract int1 int2 int3, `options' tol(`tol') nomiss

    compare_inner_contract int1 str_32 double1,                                        `options' tol(`tol')
    compare_inner_contract int1 str_32 double1 int2 str_12 double2,                    `options' tol(`tol')
    compare_inner_contract int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options' tol(`tol')
end

capture program drop compare_inner_contract
program compare_inner_contract
    syntax [anything], [tol(real 1e-6) sort shuffle *]

    tempvar rsort
    if ( "`shuffle'" != "" ) gen `rsort' = runiform()
    if ( "`shuffle'" != "" ) sort `rsort'
    if ( ("`sort'" != "") & ("`anything'" != "") ) hashsort `anything'

    local N = trim("`: di %15.0gc _N'")
    local hlen = 35 + length("`anything'") + length("`N'")
    di as txt _n(2) "Checking contract. N = `N'; varlist = `anything'" _n(1) "{hline `hlen'}"

    preserve
        _compare_inner_contract `anything', `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_contract  `anything' in `from' / `to', `options' tol(`tol')
    restore, preserve
        _compare_inner_contract `anything' if random2 > 0, `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_contract `anything' if random2 < 0 in `from' / `to', `options' tol(`tol')
    restore
end

capture program drop _compare_inner_contract
program _compare_inner_contract
    syntax [anything] [if] [in], [tol(real 1e-6) *]

    local opts freq(freq) cf(cf) p(p) cp(cp)

    preserve
        timer clear
        timer on 43
        qui `noisily' gcontract `anything' `if' `in', `opts'
        timer off 43
        qui timer list
        local time_gcontract = r(t43)
        tempfile fg
        qui save `fg'
    restore

    preserve
        timer clear
        timer on 42
        qui `noisily' contract `anything' `if' `in', `opts'
        timer off 42
        qui timer list
        local time_gcontract = r(t42)
        tempfile fc
        qui save `fc'
    restore

    preserve
    use `fc', clear
        local bad_any = 0
        local bad `anything'
        foreach var in freq cf p cp {
            rename `var' c_`var'
        }
        qui merge 1:1 `anything' using `fg', assert(3)
        foreach var in freq cf p cp {
            qui count if ( (abs(`var' - c_`var') > `tol') & (`var' != c_`var'))
            if ( `r(N)' > 0 ) {
                gen bad_`var' = abs(`var' - c_`var') * (`var' != c_`var')
                local bad `bad' *`var'
                di "    `var' has `:di r(N)' mismatches".
                local bad_any = 1
                order *`var'
            }
        }
        if ( `bad_any' ) {
            if ( "`if'`in'" == "" ) {
                di "    compare_contract (failed): full range, `anything'"
            }
            else if ( "`if'`in'" != "" ) {
                di "    compare_contract (failed): [`if' `in'], `anything'"
            }
            order `bad'
            egen bad_any = rowmax(bad_*)
            l `bad' if bad_any
            sum bad_*
            desc
            exit 9
        }
        else {
            if ( "`if'`in'" == "" ) {
                di "    compare_contract (passed): full range, gcontract results equal to contract (tol = `tol')"
            }
            else if ( "`if'`in'" != "" ) {
                di "    compare_contract (passed): [`if' `in'], gcontract results equal to contract (tol = `tol')"
            }
        }
    restore
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_contract
program bench_contract
    syntax, [tol(real 1e-6) bench(real 1) n(int 1000) NOIsily *]

    qui gen_data, n(`n') random(1) double
    qui expand `=100 * `bench''
    qui hashsort random1

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    di as txt _n(1)
    di as txt "Benchmark vs contract, obs = `N', J = `J' (in seconds)"
    di as txt "    contract | gcontract | ratio (c/g) | varlist"
    di as txt "    -------- | --------- | ----------- | -------"

    versus_contract str_12,              `options'
    versus_contract str_12 str_32,       `options'
    versus_contract str_12 str_32 str_4, `options'

    versus_contract double1,                 `options'
    versus_contract double1 double2,         `options'
    versus_contract double1 double2 double3, `options'

    versus_contract int1,           `options'
    versus_contract int1 int2,      `options'
    versus_contract int1 int2 int3, `options'

    versus_contract int1 str_32 double1,                                        `options'
    versus_contract int1 str_32 double1 int2 str_12 double2,                    `options'
    versus_contract int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    di _n(1) "{hline 80}" _n(1) "bench_contract, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_contract
program versus_contract, rclass
    syntax [anything], [*]

    local stats       ""
    local percentiles ""

    local opts freq(freq) cf(cf) p(p) cp(cp)

    preserve
        timer clear
        timer on 42
        qui contract `anything' `if' `in', `opts'
        timer off 42
        qui timer list
        local time_contract = r(t42)
    restore

    preserve
        timer clear
        timer on 43
        qui gcontract `anything' `if' `in', `opts'
        timer off 43
        qui timer list
        local time_gcontract = r(t43)
    restore

    local rs = `time_contract'  / `time_gcontract'
    di as txt "    `:di %8.3g `time_contract'' | `:di %9.3g `time_gcontract'' | `:di %11.3g `rs'' | `anything'"
end
capture program drop checks_gegen
program checks_gegen
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_egen, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(5000) random(2)
    qui expand 2
    gen long ix = _n

    checks_inner_egen, `options'

    checks_inner_egen -str_12,              `options'
    checks_inner_egen str_12 -str_32,       `options'
    checks_inner_egen str_12 -str_32 str_4, `options'

    checks_inner_egen -double1,                 `options'
    checks_inner_egen double1 -double2,         `options'
    checks_inner_egen double1 -double2 double3, `options'

    checks_inner_egen -int1,           `options'
    checks_inner_egen int1 -int2,      `options'
    checks_inner_egen int1 -int2 int3, `options'

    checks_inner_egen -int1 -str_32 -double1,                                         `options'
    checks_inner_egen int1 -str_32 double1 -int2 str_12 -double2,                     `options'
    checks_inner_egen int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options'

    clear
    gen x = 1
    cap gegen y = group(x)
    assert _rc == 111

    clear
    set obs 10
    gen x = 1
    gegen y = group(x) if x > 1
    gegen z = tag(x)   if x > 1
end

capture program drop checks_inner_egen
program checks_inner_egen
    syntax [anything], [tol(real 1e-6) *]

    local stats total sum mean sd max min count median iqr percent first last firstnm lastnm
    local percentiles 1 10 30.5 50 70.5 90 99

    tempvar gvar
    foreach fun of local stats {
        `noisily' gegen `gvar' = `fun'(random1), by(`anything') replace `options'
        `noisily' gegen `gvar' = `fun'(random*), by(`anything') replace `options'
    }

    foreach p in `percentiles' {
        `noisily' gegen `gvar' = pctile(random1), p(`p') by(`anything') replace `options'
        `noisily' gegen `gvar' = pctile(random*), p(`p') by(`anything') replace `options'
    }

    if ( "`anything'" != "" ) {
        `noisily' gegen `gvar' = tag(`anything'),   replace `options'
        `noisily' gegen `gvar' = group(`anything'), replace `options'
        `noisily' gegen `gvar' = count(1), by(`anything') replace `options'
    }
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_egen
program compare_egen
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "consistency_egen, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(1000) random(2)
    qui expand 100

    compare_inner_egen, `options' tol(`tol')

    compare_inner_egen str_12,              `options' tol(`tol')
    compare_inner_egen str_12 str_32,       `options' tol(`tol') sort
    compare_inner_egen str_12 str_32 str_4, `options' tol(`tol') shuffle

    compare_inner_egen double1,                 `options' tol(`tol') shuffle
    compare_inner_egen double1 double2,         `options' tol(`tol')
    compare_inner_egen double1 double2 double3, `options' tol(`tol') sort

    compare_inner_egen int1,           `options' tol(`tol') sort
    compare_inner_egen int1 int2,      `options' tol(`tol') shuffle
    compare_inner_egen int1 int2 int3, `options' tol(`tol')

    compare_inner_egen int1 str_32 double1,                                        `options' tol(`tol')
    compare_inner_egen int1 str_32 double1 int2 str_12 double2,                    `options' tol(`tol')
    compare_inner_egen int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options' tol(`tol')
end

capture program drop compare_inner_egen
program compare_inner_egen
    syntax [anything], [tol(real 1e-6) sort shuffle *]

    tempvar rsort
    if ( "`shuffle'" != "" ) gen `rsort' = runiform()
    if ( "`shuffle'" != "" ) sort `rsort'
    if ( ("`sort'" != "") & ("`anything'" != "") ) hashsort `anything'

    local N = trim("`: di %15.0gc _N'")
    local hlen = 31 + length("`anything'") + length("`N'")

    di _n(2) "Checking egen. N = `N'; varlist = `anything'" _n(1) "{hline `hlen'}"

    _compare_inner_egen `anything', `options' tol(`tol')

    local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
    local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
    local from = cond(`in1' < `in2', `in1', `in2')
    local to   = cond(`in1' > `in2', `in1', `in2')
    _compare_inner_egen `anything' in `from' / `to', `options' tol(`tol')

    _compare_inner_egen `anything' if random2 > 0, `options' tol(`tol')

    local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
    local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
    local from = cond(`in1' < `in2', `in1', `in2')
    local to   = cond(`in1' > `in2', `in1', `in2')
    _compare_inner_egen `anything' if random2 < 0 in `from' / `to', `options' tol(`tol')
end

capture program drop _compare_inner_egen
program _compare_inner_egen
    syntax [anything] [if] [in], [tol(real 1e-6) *]

    local stats       total sum mean sd max min count median iqr
    local percentiles 1 10 30 50 70 90 99

    cap drop g*_*
    cap drop c*_*

    tempvar g_fun

    if ( "`if'`in'" == "" ) {
        di _n(1) "Checking full egen range: `anything'"
    }
    else if ( "`if'`in'" != "" ) {
        di _n(1) "Checking [`if' `in'] egen range: `anything'"
    }

    foreach fun of local stats {
        timer clear
        timer on 43
        qui `noisily' gegen float `g_fun' = `fun'(random1) `if' `in', by(`anything') replace `options'
        timer off 43
        qui timer list
        local time_gegen = r(t43)


        timer clear
        timer on 42
        qui `noisily'  egen float c_`fun' = `fun'(random1) `if' `in', by(`anything')
        timer off 42
        qui timer list
        local time_egen = r(t42)

        local rs = `time_egen'  / `time_gegen'
        local tinfo `:di %4.3g `time_gegen'' vs `:di %4.3g `time_egen'', ratio `:di %4.3g `rs''

        cap noi assert (`g_fun' == c_`fun') | abs(`g_fun' - c_`fun') < `tol'
        if ( _rc ) {
            di as err "    compare_egen (failed): gegen `fun' not equal to egen (tol = `tol'; `tinfo')"
            exit _rc
        }
        else di as txt "    compare_egen (passed): gegen `fun' results similar to egen (tol = `tol'; `tinfo')"
    }

    foreach p in `percentiles' {
        timer clear
        timer on 43
        qui  `noisily' gegen float `g_fun' = pctile(random1) `if' `in', by(`anything') p(`p') replace `options'
        timer off 43
        qui timer list
        local time_gegen = r(t43)


        timer clear
        timer on 42
        qui  `noisily'  egen float c_p`p'  = pctile(random1) `if' `in', by(`anything') p(`p')
        timer off 42
        qui timer list
        local time_egen = r(t42)

        local rs = `time_egen'  / `time_gegen'
        local tinfo `:di %4.3g `time_gegen'' vs `:di %4.3g `time_egen'', ratio `:di %4.3g `rs''

        cap noi assert (`g_fun' == c_p`p') | abs(`g_fun' - c_p`p') < `tol'
        if ( _rc ) {
            di as err "    compare_egen (failed): gegen percentile `p' not equal to egen (tol = `tol'; `tinfo')"
            exit _rc
        }
        else di as txt "    compare_egen (passed): gegen percentile `p' results similar to egen (tol = `tol'; `tinfo')"
    }

    foreach fun in tag group {
        timer clear
        timer on 43
        qui  `noisily' gegen float `g_fun' = `fun'(`anything') `if' `in', replace `options'
        timer off 43
        qui timer list
        local time_gegen = r(t43)


        timer clear
        timer on 42
        qui  `noisily'  egen float c_`fun' = `fun'(`anything') `if' `in'
        timer off 42
        qui timer list
        local time_egen = r(t42)

        local rs = `time_egen'  / `time_gegen'
        local tinfo `:di %4.3g `time_gegen'' vs `:di %4.3g `time_egen'', ratio `:di %4.3g `rs''

        cap noi assert (`g_fun' == c_`fun') | abs(`g_fun' - c_`fun') < `tol'
        if ( _rc ) {
            di as err "    compare_egen (failed): gegen `fun' not equal to egen (tol = `tol'; `tinfo')"
            exit _rc
        }
        else di as txt "    compare_egen (passed): gegen `fun' results similar to egen (tol = `tol'; `tinfo')"

        timer clear
        timer on 43
        qui  `noisily' gegen float `g_fun' = `fun'(`anything') `if' `in', missing replace `options'
        timer off 43
        qui timer list
        local time_gegen = r(t43)


        timer clear
        timer on 42
        qui  `noisily'  egen float c_`fun'2 = `fun'(`anything') `if' `in', missing
        timer off 42
        qui timer list
        local time_egen = r(t42)

        local rs = `time_egen'  / `time_gegen'
        local tinfo `:di %4.3g `time_gegen'' vs `:di %4.3g `time_egen'', ratio `:di %4.3g `rs''

        cap noi assert (`g_fun' == c_`fun'2) | abs(`g_fun' - c_`fun'2) < `tol'
        if ( _rc ) {
            di as err "    compare_egen (failed): gegen `fun', missing not equal to egen (tol = `tol'; `tinfo')"
            exit _rc
        }
        else di as txt "    compare_egen (passed): gegen `fun', missing results similar to egen (tol = `tol'; `tinfo')"
    }

    {
        qui  `noisily' gegen g_g1 = group(`anything') `if' `in', counts(g_c1) fill(.) v `options' missing
        qui  `noisily' gegen g_g2 = group(`anything') `if' `in', counts(g_c2)         v `options' missing
        qui  `noisily' gegen g_c3 = count(1) `if' `in', by(`anything')
        qui  `noisily'  egen c_t1 = tag(`anything') `if' `in',  missing
        cap noi assert ( (g_c1 == g_c3) | ((c_t1 == 0) & (g_c1 == .)) ) & (g_c2 == g_c3)
        if ( _rc ) {
            di as err "    compare_egen (failed): gegen `fun' counts not equal to gegen count (tol = `tol')"
            exit _rc
        }
        else di as txt "    compare_egen (passed): gegen `fun' counts results similar to gegen count (tol = `tol')"
    }

    cap drop g_*
    cap drop c_*
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_egen
program bench_egen
    syntax, [tol(real 1e-6) bench(int 1) n(int 1000) NOIsily *]

    qui gen_data, n(`n') random(1)
    qui expand `=100 * `bench''
    qui sort random1

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    di _n(1)
    di "Benchmark vs egen, obs = `N', J = `J' (in seconds)"
    di "     egen | fegen | gegen | ratio (e/g) | ratio (f/g) | varlist"
    di "     ---- | ----- | ----- | ----------- | ----------- | -------"

    versus_egen str_12,              `options' fegen
    versus_egen str_12 str_32,       `options' fegen
    versus_egen str_12 str_32 str_4, `options' fegen

    versus_egen double1,                 `options' fegen
    versus_egen double1 double2,         `options' fegen
    versus_egen double1 double2 double3, `options' fegen

    versus_egen int1,           `options' fegen
    versus_egen int1 int2,      `options' fegen
    versus_egen int1 int2 int3, `options' fegen

    versus_egen int1 str_32 double1,                                        `options'
    versus_egen int1 str_32 double1 int2 str_12 double2,                    `options'
    versus_egen int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    di _n(1) "{hline 80}" _n(1) "bench_egen, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_egen
program versus_egen, rclass
    syntax varlist, [fegen *]

    preserve
        timer clear
        timer on 42
        cap egen id = group(`varlist')
        timer off 42
        qui timer list
        local time_egen = r(t42)
    restore

    preserve
        timer clear
        timer on 43
        cap gegen id = group(`varlist'), `options'
        timer off 43
        qui timer list
        local time_gegen = r(t43)
    restore

    if ( "`fegen'" == "fegen" ) {
    preserve
        timer clear
        timer on 44
        cap fegen id = group(`varlist')
        timer off 44
        qui timer list
        local time_fegen = r(t44)
    restore
    }
    else {
        local time_fegen = .
    }

    local rs = `time_egen'  / `time_gegen'
    local rf = `time_fegen' / `time_gegen'
    di "    `:di %5.3g `time_egen'' | `:di %5.3g `time_fegen'' | `:di %5.3g `time_gegen'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `varlist'"
end
capture program drop checks_unique
program checks_unique
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_unique, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(5000)
    qui expand 2
    gen long ix = _n

    checks_inner_unique str_12,              `options'
    checks_inner_unique str_12 str_32,       `options' by(str_4) replace
    checks_inner_unique str_12 str_32 str_4, `options'

    checks_inner_unique double1,                 `options'
    checks_inner_unique double1 double2,         `options' by(double3) replace
    checks_inner_unique double1 double2 double3, `options'

    checks_inner_unique int1,           `options'
    checks_inner_unique int1 int2,      `options' by(int3) replace
    checks_inner_unique int1 int2 int3, `options'

    checks_inner_unique int1 str_32 double1,                                        `options'
    checks_inner_unique int1 str_32 double1 int2 str_12 double2,                    `options' by(int3 str_4 double3) replace
    checks_inner_unique int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    clear
    gen x = 1
    cap gunique x
    assert _rc == 2000

    clear
    set obs 10
    gen x = 1
    cap gunique x if x < 0
    assert _rc == 0
end

capture program drop checks_inner_unique
program checks_inner_unique
    syntax varlist, [*]
    cap gunique `varlist', `options' v bench miss
    assert _rc == 0

    cap gunique `varlist' in 1, `options' miss d
    assert _rc == 0
    assert `r(N)' == `r(J)'
    assert `r(J)' == 1

    cap gunique `varlist' if _n == 1, `options' miss
    assert _rc == 0
    assert `r(N)' == `r(J)'
    assert `r(J)' == 1

    cap gunique `varlist' if _n < 10 in 5, `options' miss d
    assert _rc == 0
    assert `r(N)' == `r(J)'
    assert `r(J)' == 1
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_unique
program compare_unique
    syntax, [tol(real 1e-6) NOIsily distinct unique *]

    if ( "`distinct'`unique'" == "" ) local unique unique
    if ( ("`distinct'" != "") & ("`unique'" != "") ) {
        di as err "Specify only one of: unique distinct"
        exit 198
    }

    qui `noisily' gen_data, n(1000)
    qui expand 100

    local N    = trim("`: di %15.0gc _N'")
    local hlen = 22 + length("`options'") + length("`N'")
    di _n(1) "{hline 80}" _n(1) "compare_`distinct'`unique', N = `N', `options'" _n(1) "{hline 80}" _n(1)

    local options `options' `distinct'`unique'

    compare_inner_unique str_12,              `options' sort
    compare_inner_unique str_12 str_32,       `options' shuffle
    compare_inner_unique str_12 str_32 str_4, `options'

    compare_inner_unique double1,                 `options'
    compare_inner_unique double1 double2,         `options' sort
    compare_inner_unique double1 double2 double3, `options' shuffle

    compare_inner_unique int1,           `options' shuffle
    compare_inner_unique int1 int2,      `options'
    compare_inner_unique int1 int2 int3, `options' sort

    compare_inner_unique int1 str_32 double1,                                        `options'
    compare_inner_unique int1 str_32 double1 int2 str_12 double2,                    `options'
    compare_inner_unique int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'
end

capture program drop compare_inner_unique
program compare_inner_unique
    syntax varlist, [distinct unique sort shuffle *]

    tempvar rsort
    if ( "`shuffle'" != "" ) gen `rsort' = runiform()
    if ( "`shuffle'" != "" ) sort `rsort'
    if ( ("`sort'" != "") & ("`anything'" != "") ) hashsort `anything'

    if ( "`distinct'" != "" ) {
        local joint joint
        local rname ndistinct
    }
    else {
        local joint
        local rname unique
    }

    local options `options' `joint'

    tempvar rsort ix
    gen `rsort' = runiform()
    gen long `ix' = _n

    cap `distinct'`unique' `varlist', `joint'
    local nJ_`distinct'`unique' = `r(`rname')'
    cap g`distinct'`unique' `varlist', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( `varlist') `distinct'`unique'

    cap `distinct'`unique' `ix' `varlist', `joint'
    local nJ_`distinct'`unique' = `r(`rname')'
    cap g`distinct'`unique' `ix' `varlist', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist') `distinct'`unique'

    cap `distinct'`unique' `rsort' `varlist', `joint'
    local nJ_`distinct'`unique' = `r(`rname')'
    cap g`distinct'`unique' `rsort' `varlist', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( rsort `varlist') `distinct'`unique'

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    qui replace `ix' = `=_N / 2' if _n > `=_N / 2'
    cap `distinct'`unique' `ix', `joint'
    local nJ_`distinct'`unique' = `r(`rname')'
    cap g`distinct'`unique' `ix', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix) `distinct'`unique'

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    preserve
        qui keep in 100 / `=ceil(`=_N / 2')'
        cap `distinct'`unique' `ix' `varlist', `joint'
        local nJ_`distinct'`unique' = `r(`rname')'
    restore
    cap g`distinct'`unique' `ix' `varlist' in 100 / `=ceil(`=_N / 2')', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels  `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist' in 100 / `=ceil(`=_N / 2')') `distinct'`unique'

    preserve
        qui keep in `=ceil(`=_N / 2')' / `=_N'
        cap `distinct'`unique' `ix' `varlist', `joint'
        local nJ_`distinct'`unique' = `r(`rname')'
    restore
    cap g`distinct'`unique' `ix' `varlist' in `=ceil(`=_N / 2')' / `=_N', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels  `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist' in `=ceil(`=_N / 2')' / `=_N') `distinct'`unique'

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    preserve
        qui keep if _n < `=_N / 2'
        cap `distinct'`unique' `ix' `varlist', `joint'
        local nJ_`distinct'`unique' = `r(`rname')'
    restore
    cap g`distinct'`unique' `ix' `varlist' if _n < `=_N / 2', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels  `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist' if _n < `=_N / 2') `distinct'`unique'

    preserve
        qui keep if _n > `=_N / 2'
        cap `distinct'`unique' `ix' `varlist', `joint'
        local nJ_`distinct'`unique' = `r(`rname')'
    restore
    cap g`distinct'`unique' `ix' `varlist' if _n > `=_N / 2', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels  `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist' if _n > `=_N / 2') `distinct'`unique'

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    qui replace `ix' = 100 in 1 / 100

    preserve
        qui keep if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')'
        cap `distinct'`unique' `ix' `varlist', `joint'
        local nJ_`distinct'`unique' = `r(`rname')'
    restore
    cap g`distinct'`unique' `ix' `varlist' if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels  `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist' if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')') `distinct'`unique'

    preserve
        qui keep if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N'
        cap `distinct'`unique' `ix' `varlist', `joint'
        local nJ_`distinct'`unique' = `r(`rname')'
    restore
    cap g`distinct'`unique' `ix' `varlist' if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N', `options'
    local nJ_g`distinct'`unique' = `r(`rname')'
    check_nlevels  `nJ_`distinct'`unique'' `nJ_g`distinct'`unique'' , by( ix `varlist' if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N') `distinct'`unique'

    di _n(1)
end

capture program drop check_nlevels
program check_nlevels
    syntax anything, by(str) [distinct unique]

    tokenize `anything'
    local nJ   `1'
    local nJ_g `2'

    if ( `nJ' != `nJ_g' ) {
        di as err "    compare_`distinct'`unique' (failed): `distinct'`unique' `by' gave `nJ' levels but g`distinct'`unique' gave `nJ_g'"
        exit 198
    }
    else {
        di as txt "    compare_`distinct'`unique' (passed): `distinct'`unique' and g`distinct'`unique' `by' gave the same number of levels"
    }
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_unique
program bench_unique
    syntax, [tol(real 1e-6) bench(int 1) n(int 1000) NOIsily distinct joint distunique *]

    if ( "`distinct'" != "" ) {
        local dstr distinct
        local dsep --------
    }
    else {
        local dstr unique
        local dsep ------
    }

    if ( "`joint'" != "" ) {
        local dj   , joint;
    }
    else {
        local dj   ,
    }

    local options `options' `distinct' `joint' `distunique'

    qui `noisily' gen_data, n(`n')
    qui expand `=100 * `bench''
    qui gen rsort = rnormal()
    qui sort rsort

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    if ( ("`distunique'" != "") & ("`joint'" != "") ) {
        di as txt _n(1)
        di as txt "Benchmark vs `dstr'`dj' obs = `N', all calls include a unique index (in seconds)"
        di as txt "     `dstr' |    unique | g`dstr' | ratio (d/g) | ratio (u/g) | varlist"
        di as txt "     `dsep' | -`dsep' | -`dsep' | ----------- | ----------- | -------"
    }
    else {
        di as txt _n(1)
        di as txt "Benchmark vs `dstr'`dj' obs = `N', all calls include a unique index (in seconds)"
        di as txt "     `dstr' | f`dstr' | g`dstr' | ratio (d/g) | ratio (u/g) | varlist"
        di as txt "     `dsep' | -`dsep' | -`dsep' | ----------- | ----------- | -------"
    }

    versus_unique str_12,              `options' funique unique
    versus_unique str_12 str_32,       `options' funique unique
    versus_unique str_12 str_32 str_4, `options' funique unique

    versus_unique double1,                 `options' funique unique
    versus_unique double1 double2,         `options' funique unique
    versus_unique double1 double2 double3, `options' funique unique

    versus_unique int1,           `options' funique unique
    versus_unique int1 int2,      `options' funique unique
    versus_unique int1 int2 int3, `options' funique unique

    versus_unique int1 str_32 double1,                                        unique `options'
    versus_unique int1 str_32 double1 int2 str_12 double2,                    unique `options'
    versus_unique int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, unique `options'

    if ( ("`distunique'" != "") & ("`joint'" != "") ) {
        di as txt _n(1)
        di as txt "Benchmark vs `dstr'`dj' obs = `N', J = `J' (in seconds)"
        di as txt "     `dstr' |    unique | g`dstr' | ratio (d/g) | ratio (u/g) | varlist"
        di as txt "     `dsep' | -`dsep' | -`dsep' | ----------- | ----------- | -------"
    }
    else {
        di as txt _n(1)
        di as txt "Benchmark vs `dstr'`dj' obs = `N', J = `J' (in seconds)"
        di as txt "     `dstr' | f`dstr' | g`dstr' | ratio (u/g) | ratio (f/g) | varlist"
        di as txt "     `dsep' | -`dsep' | -`dsep' | ----------- | ----------- | -------"
    }

    versus_unique str_12,              `options' funique
    versus_unique str_12 str_32,       `options' funique
    versus_unique str_12 str_32 str_4, `options' funique

    versus_unique double1,                 `options' funique
    versus_unique double1 double2,         `options' funique
    versus_unique double1 double2 double3, `options' funique

    versus_unique int1,           `options' funique
    versus_unique int1 int2,      `options' funique
    versus_unique int1 int2 int3, `options' funique

    versus_unique int1 str_32 double1,                                        `options'
    versus_unique int1 str_32 double1 int2 str_12 double2,                    `options'
    versus_unique int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    di as txt _n(1) "{hline 80}" _n(1) "bench_unique, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_unique
program versus_unique, rclass
    syntax varlist, [funique unique distinct joint distunique *]
    if ( "`unique'" == "unique" ) {
        tempvar ix
        gen `ix' = `=_N' - _n
        if ( strpos("`varlist'", "str") ) qui tostring `ix', replace
    }

    preserve
        timer clear
        timer on 42
        cap unique `varlist' `ix'
        assert inlist(_rc, 0, 459)
        timer off 42
        qui timer list
        local time_unique = r(t42)
    restore

    preserve
        timer clear
        timer on 43
        cap gunique `varlist' `ix', `options'
        assert inlist(_rc, 0, 459)
        timer off 43
        qui timer list
        local time_gunique = r(t43)
    restore

    if ( ("`funique'" == "funique") & ("`distinct'" == "") ) {
    preserve
        timer clear
        timer on 44
        cap funique `varlist' `ix'
        assert inlist(_rc, 0, 459)
        timer off 44
        qui timer list
        local time_funique = r(t44)
    restore
    }
    else if ( "`distunique'" != "" ) {
    preserve
        timer clear
        timer on 44
        cap unique `varlist' `ix'
        assert inlist(_rc, 0, 459)
        timer off 44
        qui timer list
        local time_funique = r(t44)
    restore
    }
    else {
        local time_funique = .
    }

    local rs = `time_unique'  / `time_gunique'
    local rf = `time_funique' / `time_gunique'

    if ( "`distinct'" == "" ) {
    di as txt "    `:di %7.3g `time_unique'' | `:di %7.3g `time_funique'' | `:di %7.3g `time_gunique'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `varlist'"
    }
    else {
    di as txt "    `:di %9.3g `time_unique'' | `:di %9.3g `time_funique'' | `:di %9.3g `time_gunique'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `varlist'"
    }
end

* Prototype of -unique-
* ---------------------

cap mata: mata drop funique()
cap pr drop funique
program funique
	syntax varlist [if] [in], [Detail]
	
	mata: funique("`varlist'", "`detail'"!="")
end

mata:
mata set matastrict off
void funique(string scalar varlist, real scalar detail)
{
	class Factor scalar F
	F = factor(varlist)
	printf("{txt}Number of unique values of turn is {res}%-11.0f{txt}\n", F.num_levels)
	printf("{txt}Number of records is {res}%-11.0f{txt}\n", F.num_obs)
	if (detail) {
		(void) st_addvar("long", tempvar=st_tempname())
		st_store(1::F.num_levels, tempvar, F.counts)
		st_varlabel(tempvar, "Records per " + invtokens(F.varlist))
		stata("su " + tempvar + ", detail")
	}
}
end
capture program drop checks_levelsof
program checks_levelsof
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_levelsof, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(50)
    qui expand 200
    gen long ix = _n

    checks_inner_levelsof str_12,              `options'
    checks_inner_levelsof str_12 str_32,       `options'
    checks_inner_levelsof str_12 str_32 str_4, `options'

    checks_inner_levelsof double1,                 `options'
    checks_inner_levelsof double1 double2,         `options'
    checks_inner_levelsof double1 double2 double3, `options'

    checks_inner_levelsof int1,           `options'
    checks_inner_levelsof int1 int2,      `options'
    checks_inner_levelsof int1 int2 int3, `options'

    checks_inner_levelsof int1 str_32 double1,                                        `options'
    checks_inner_levelsof int1 str_32 double1 int2 str_12 double2,                    `options'
    checks_inner_levelsof int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    clear
    gen x = 1
    cap glevelsof x
    assert _rc == 2000

    clear
    set obs 100000
    gen x = _n
    cap glevelsof x in 1 / 10000 if mod(x, 3) == 0
    assert _rc == 0
end

capture program drop checks_inner_levelsof
program checks_inner_levelsof
    syntax varlist, [*]
    cap noi glevelsof `varlist', `options' v bench clean silent
    assert _rc == 0

    cap glevelsof `varlist' in 1, `options' silent miss
    assert _rc == 0

    cap glevelsof `varlist' in 1, `options' miss
    assert _rc == 0

    cap glevelsof `varlist' if _n == 1, `options' local(hi) miss
    assert _rc == 0
    assert `"`r(levels)'"' == `"`hi'"'

    cap glevelsof `varlist' if _n < 10 in 5, `options' s(" | ") cols(", ") miss
    assert _rc == 0
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_levelsof
program compare_levelsof
    syntax, [tol(real 1e-6) NOIsily *]

    qui `noisily' gen_data, n(50)
    qui expand 10000

    local N    = trim("`: di %15.0gc _N'")
    local hlen = 24 + length("`options'") + length("`N'")
    di _n(1) "{hline 80}" _n(1) "compare_levelsof, N = `N', `options'" _n(1) "{hline 80}" _n(1)

    compare_inner_levelsof str_12, `options' sort
    compare_inner_levelsof str_32, `options' shuffle
    compare_inner_levelsof str_4,  `options'

    compare_inner_levelsof double1, `options' round
    compare_inner_levelsof double2, `options' round sort
    compare_inner_levelsof double3, `options' round shuffle

    compare_inner_levelsof int1, `options' shuffle
    compare_inner_levelsof int2, `options'
    compare_inner_levelsof int3, `options' sort
end

capture program drop compare_inner_levelsof
program compare_inner_levelsof
    syntax varlist, [round shuffle sort *]

    tempvar rsort
    if ( "`shuffle'" != "" ) gen `rsort' = runiform()
    if ( "`shuffle'" != "" ) sort `rsort'
    if ( ("`sort'" != "") & ("`anything'" != "") ) hashsort `anything'

    cap  levelsof `varlist', s(" | ") local(l_stata)
    cap glevelsof `varlist', s(" | ") local(l_gtools) `options'
    if ( `"`l_stata'"' != `"`l_gtools'"' ) {
        if ( "`round'" != "" ) {
            while ( `"`l_stata'`l_gtools'"' != "" ) {
                gettoken l_scmp l_stata:  l_stata,  p(" | ")
                gettoken _      l_stata:  l_stata,  p(" | ")
                gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                gettoken _      l_gtools: l_gtools, p(" | ")
                if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                    cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                    if ( _rc ) {
                        di as err "    compare_levelsof (failed): glevelsof `varlist' returned different levels with rounding"
                        exit 198
                    }
                }
            }
            di as txt "    compare_levelsof (passed): glevelsof `varlist' returned similar levels as levelsof (tol = 1e-15)"
        }
        else {
            di as err "    compare_levelsof (failed): glevelsof `varlist' returned different levels to levelsof"
            exit 198
        }
    }
    else {
        di as txt "    compare_levelsof (passed): glevelsof `varlist' returned the same levels as levelsof"
    }

    cap  levelsof `varlist', local(l_stata)  miss
    cap glevelsof `varlist', local(l_gtools) miss `options'
    if ( `"`l_stata'"' != `"`l_gtools'"' ) {
        if ( "`round'" != "" ) {
            while ( `"`l_stata'`l_gtools'"' != "" ) {
                gettoken l_scmp l_stata:  l_stata,  p(" | ")
                gettoken _      l_stata:  l_stata,  p(" | ")
                gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                gettoken _      l_gtools: l_gtools, p(" | ")
                if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                    cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                    if ( _rc ) {
                        di as err "    compare_levelsof (failed): glevelsof `varlist' returned different levels with rounding"
                        exit 198
                    }
                }
            }
            di as txt "    compare_levelsof (passed): glevelsof `varlist' returned similar levels as levelsof (tol = 1e-15)"
        }
        else {
            di as err "    compare_levelsof (failed): glevelsof `varlist' returned different levels to levelsof"
            exit 198
        }
    }
    else {
        di as txt "    compare_levelsof (passed): glevelsof `varlist' returned the same levels as levelsof"
    }

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

        cap  levelsof `varlist' in 100 / `=ceil(`=_N / 2')', local(l_stata)  miss
        cap glevelsof `varlist' in 100 / `=ceil(`=_N / 2')', local(l_gtools) miss `options'
        if ( `"`l_stata'"' != `"`l_gtools'"' ) {
            if ( "`round'" != "" ) {
                while ( `"`l_stata'`l_gtools'"' != "" ) {
                    gettoken l_scmp l_stata:  l_stata,  p(" | ")
                    gettoken _      l_stata:  l_stata,  p(" | ")
                    gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                    gettoken _      l_gtools: l_gtools, p(" | ")
                    if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                        cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                        if ( _rc ) {
                            di as err "    compare_levelsof (failed): glevelsof `varlist' [in] returned different levels with rounding"
                            exit 198
                        }
                    }
                }
                di as txt "    compare_levelsof (passed): glevelsof `varlist' [in] returned similar levels as levelsof (tol = 1e-15)"
            }
            else {
                di as err "    compare_levelsof (failed): glevelsof `varlist' [in] returned different levels to levelsof"
                exit 198
            }
        }
        else {
            di as txt "    compare_levelsof (passed): glevelsof `varlist' [in] returned the same levels as levelsof"
        }

        cap glevelsof `varlist' in `=ceil(`=_N / 2')' / `=_N', local(l_stata)
        cap glevelsof `varlist' in `=ceil(`=_N / 2')' / `=_N', local(l_gtools) `options'
        if ( `"`l_stata'"' != `"`l_gtools'"' ) {
            if ( "`round'" != "" ) {
                while ( `"`l_stata'`l_gtools'"' != "" ) {
                    gettoken l_scmp l_stata:  l_stata,  p(" | ")
                    gettoken _      l_stata:  l_stata,  p(" | ")
                    gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                    gettoken _      l_gtools: l_gtools, p(" | ")
                    if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                        cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                        if ( _rc ) {
                            di as err "    compare_levelsof (failed): glevelsof `varlist' [in] returned different levels with rounding"
                            exit 198
                        }
                    }
                }
                di as txt "    compare_levelsof (passed): glevelsof `varlist' [in] returned similar levels as levelsof (tol = 1e-15)"
            }
            else {
                di as err "    compare_levelsof (failed): glevelsof `varlist' [in] returned different levels to levelsof"
                exit 198
            }
        }
        else {
            di as txt "    compare_levelsof (passed): glevelsof `varlist' [in] returned the same levels as levelsof"
        }

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

        cap  levelsof `varlist' if _n > `=_N / 2', local(l_stata)  miss
        cap glevelsof `varlist' if _n > `=_N / 2', local(l_gtools) miss `options'
        if ( `"`l_stata'"' != `"`l_gtools'"' ) {
            if ( "`round'" != "" ) {
                while ( `"`l_stata'`l_gtools'"' != "" ) {
                    gettoken l_scmp l_stata:  l_stata,  p(" | ")
                    gettoken _      l_stata:  l_stata,  p(" | ")
                    gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                    gettoken _      l_gtools: l_gtools, p(" | ")
                    if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                        cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                        if ( _rc ) {
                            di as err "    compare_levelsof (failed): glevelsof `varlist' [if] returned different levels with rounding"
                            exit 198
                        }
                    }
                }
                di as txt "    compare_levelsof (passed): glevelsof `varlist' [if] returned similar levels as levelsof (tol = 1e-15)"
            }
            else {
                di as err "    compare_levelsof (failed): glevelsof `varlist' [if] returned different levels to levelsof"
                exit 198
            }
        }
        else {
            di as txt "    compare_levelsof (passed): glevelsof `varlist' [if] returned the same levels as levelsof"
        }

        cap glevelsof `varlist' if _n < `=_N / 2', local(l_stata)
        cap glevelsof `varlist' if _n < `=_N / 2', local(l_gtools) `options'
        if ( `"`l_stata'"' != `"`l_gtools'"' ) {
            if ( "`round'" != "" ) {
                while ( `"`l_stata'`l_gtools'"' != "" ) {
                    gettoken l_scmp l_stata:  l_stata,  p(" | ")
                    gettoken _      l_stata:  l_stata,  p(" | ")
                    gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                    gettoken _      l_gtools: l_gtools, p(" | ")
                    if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                        cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                        if ( _rc ) {
                            di as err "    compare_levelsof (failed): glevelsof `varlist' [if] returned different levels with rounding"
                            exit 198
                        }
                    }
                }
                di as txt "    compare_levelsof (passed): glevelsof `varlist' [if] returned similar levels as levelsof (tol = 1e-15)"
            }
            else {
                di as err "    compare_levelsof (failed): glevelsof `varlist' [if] returned different levels to levelsof"
                exit 198
            }
        }
        else {
            di as txt "    compare_levelsof (passed): glevelsof `varlist' [if] returned the same levels as levelsof"
        }

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

        cap  levelsof `varlist' if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')', local(l_stata)  miss
        cap glevelsof `varlist' if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')', local(l_gtools) miss `options'
        if ( `"`l_stata'"' != `"`l_gtools'"' ) {
            if ( "`round'" != "" ) {
                while ( `"`l_stata'`l_gtools'"' != "" ) {
                    gettoken l_scmp l_stata:  l_stata,  p(" | ")
                    gettoken _      l_stata:  l_stata,  p(" | ")
                    gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                    gettoken _      l_gtools: l_gtools, p(" | ")
                    if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                        cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                        if ( _rc ) {
                            di as err "    compare_levelsof (failed): glevelsof `varlist' [if] [in] returned different levels with rounding"
                            exit 198
                        }
                    }
                }
                di as txt "    compare_levelsof (passed): glevelsof `varlist'  if] [in] returned similar levels as levelsof (tol = 1e-15)"
            }
            else {
                di as err "    compare_levelsof (failed): glevelsof `varlist' [if] [in] returned different levels to levelsof"
                exit 198
            }
        }
        else {
            di as txt "    compare_levelsof (passed): glevelsof `varlist' [if] [in] returned the same levels as levelsof"
        }

        cap glevelsof `varlist' if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N', local(l_stata)
        cap glevelsof `varlist' if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N', local(l_gtools) `options'
        if ( `"`l_stata'"' != `"`l_gtools'"' ) {
            if ( "`round'" != "" ) {
                while ( `"`l_stata'`l_gtools'"' != "" ) {
                    gettoken l_scmp l_stata:  l_stata,  p(" | ")
                    gettoken _      l_stata:  l_stata,  p(" | ")
                    gettoken l_gcmp l_gtools: l_gtools, p(" | ")
                    gettoken _      l_gtools: l_gtools, p(" | ")
                    if ( `"`l_gcmp'"' != `"`l_scmp'"' ) {
                        cap assert abs(`l_gcmp' - `l_scmp') < 1e-15
                        if ( _rc ) {
                            di as err "    compare_levelsof (failed): glevelsof `varlist' [if] [in] returned different levels with rounding"
                            exit 198
                        }
                    }
                }
                di as txt "    compare_levelsof (passed): glevelsof `varlist'  if] [in] returned similar levels as levelsof (tol = 1e-15)"
            }
            else {
                di as err "    compare_levelsof (failed): glevelsof `varlist' [if] [in] returned different levels to levelsof"
                exit 198
            }
        }
        else {
            di as txt "    compare_levelsof (passed): glevelsof `varlist' [if] [in] returned the same levels as levelsof"
        }

    di _n(1)
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_levelsof
program bench_levelsof
    syntax, [tol(real 1e-6) bench(int 1) n(int 100) NOIsily *]

    qui `noisily' gen_data, n(`n')
    qui expand `=1000 * `bench''
    qui gen rsort = rnormal()
    qui sort rsort

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    di as txt _n(1)
    di as txt "Benchmark vs levelsof, obs = `N', J = `J' (in seconds)"
    di as txt "    levelsof | flevelsof | glevelsof | ratio (l/g) | ratio (f/g) | varlist"
    di as txt "    -------- | --------- | --------- | ----------- | ----------- | -------"

    versus_levelsof str_12, `options' flevelsof
    versus_levelsof str_32, `options' flevelsof
    versus_levelsof str_4,  `options' flevelsof

    versus_levelsof double1, `options' flevelsof
    versus_levelsof double2, `options' flevelsof
    versus_levelsof double3, `options' flevelsof

    versus_levelsof int1, `options' flevelsof
    versus_levelsof int2, `options' flevelsof
    versus_levelsof int3, `options' flevelsof

    di as txt _n(1) "{hline 80}" _n(1) "bench_levelsof, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_levelsof
program versus_levelsof, rclass
    syntax varlist, [flevelsof unique *]
    if ( "`unique'" == "unique" ) {
        tempvar ix
        gen `ix' = `=_N' - _n
        if ( strpos("`varlist'", "str") ) qui tostring `ix', replace
    }

    preserve
        timer clear
        timer on 42
        qui levelsof `varlist' `ix'
        timer off 42
        qui timer list
        local time_levelsof = r(t42)
    restore

    preserve
        timer clear
        timer on 43
        qui glevelsof `varlist' `ix', `options'
        timer off 43
        qui timer list
        local time_glevelsof = r(t43) 
    restore

    if ( "`flevelsof'" == "flevelsof" ) {
    preserve
        timer clear
        timer on 44
        qui flevelsof `varlist' `ix'
        timer off 44
        qui timer list
        local time_flevelsof = r(t44)
    restore
    }
    else {
        local time_flevelsof = .
    }

    local rs = `time_levelsof'  / `time_glevelsof'
    local rf = `time_flevelsof' / `time_glevelsof'
    di as txt "    `:di %8.3g `time_levelsof'' | `:di %9.3g `time_flevelsof'' | `:di %9.3g `time_glevelsof'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `varlist'"
end
capture program drop checks_toplevelsof
program checks_toplevelsof
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_toplevelsof, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(50)
    qui expand 200
    gen long ix = _n

    checks_inner_toplevelsof -str_12,              `options'
    checks_inner_toplevelsof str_12 -str_32,       `options'
    checks_inner_toplevelsof str_12 -str_32 str_4, `options'

    checks_inner_toplevelsof -double1,                 `options'
    checks_inner_toplevelsof double1 -double2,         `options'
    checks_inner_toplevelsof double1 -double2 double3, `options'

    checks_inner_toplevelsof -int1,           `options'
    checks_inner_toplevelsof int1 -int2,      `options'
    checks_inner_toplevelsof int1 -int2 int3, `options'

    checks_inner_toplevelsof -int1 -str_32 -double1,                                         `options'
    checks_inner_toplevelsof int1 -str_32 double1 -int2 str_12 -double2,                     `options'
    checks_inner_toplevelsof int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options'

    clear
    gen x = 1
    gtoplevelsof x

    clear
    set obs 100000
    gen x = _n
    gtoplevelsof x in 1 / 10000 if mod(x, 3) == 0
    gtoplevelsof x if _n < 1
end

capture program drop checks_inner_toplevelsof
program checks_inner_toplevelsof
    syntax anything, [*]
    gtoplevelsof `anything' in 1, `options' miss
    gtoplevelsof `anything' in 1, `options' miss
    gtoplevelsof `anything' if _n == 1, `options' local(hi) miss
    gtoplevelsof `anything' if _n < 10 in 5, `options' s(" | ") cols(", ") miss
    gtoplevelsof `anything', `options' v bench
    gtoplevelsof `anything', `options' ntop(2)
    gtoplevelsof `anything', `options' ntop(0)
    gtoplevelsof `anything', `options' ntop(0) noother
    gtoplevelsof `anything', `options' ntop(0) missrow
    gtoplevelsof `anything', `options' freqabove(10000)
    gtoplevelsof `anything', `options' pctabove(5)
    gtoplevelsof `anything', `options' pctabove(100)
    gtoplevelsof `anything', `options' pctabove(100) noother
    gtoplevelsof `anything', `options' groupmiss
    gtoplevelsof `anything', `options' nomiss
    gtoplevelsof `anything', `options' nooth
    gtoplevelsof `anything', `options' oth
    gtoplevelsof `anything', `options' oth(I'm some other group)
    gtoplevelsof `anything', `options' missrow
    gtoplevelsof `anything', `options' missrow(Hello, I'm missing)
    gtoplevelsof `anything', `options' pctfmt(%15.6f)
    gtoplevelsof `anything', `options' novaluelab
    gtoplevelsof `anything', `options' hidecont
    gtoplevelsof `anything', `options' varabb(5)
    gtoplevelsof `anything', `options' colmax(3)
    gtoplevelsof `anything', `options' colstrmax(2)
    gtoplevelsof `anything', `options' numfmt(%9.4f)
    gtoplevelsof `anything', `options' s(", ") cols(" | ")
    gtoplevelsof `anything', `options' v bench
    gtoplevelsof `anything', `options' colstrmax(0) numfmt(%.5g) colmax(0) varabb(1) freqabove(100) nooth
    gtoplevelsof `anything', `options' missrow nooth groupmiss pctabove(2.5)
    gtoplevelsof `anything', `options' missrow groupmiss pctabove(2.5)
    gtoplevelsof `anything', `options' missrow groupmiss pctabove(99)
    gtoplevelsof `anything', `options' s(|) cols(<<) missrow("I am missing ):")
    gtoplevelsof `anything', `options' s(|) cols(<<) matrix(zz) loc(oo)
    gtoplevelsof `anything', `options' loc(toplevels) mat(topmat)
    disp `"`toplevels'"'
    matrix list topmat
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_toplevelsof
program compare_toplevelsof
    syntax, [tol(real 1e-6) NOIsily *]

    qui `noisily' gen_data, n(1000) random(2)
    qui expand 100

    local N = trim("`: di %15.0gc _N'")
    di _n(1) "{hline 80}" _n(1) "consistency_gtoplevelsof_gcontract, N = `N', `options'" _n(1) "{hline 80}" _n(1)

    compare_inner_gtoplevelsof -str_12,              `options' tol(`tol')
    compare_inner_gtoplevelsof str_12 -str_32,       `options' tol(`tol')
    compare_inner_gtoplevelsof str_12 -str_32 str_4, `options' tol(`tol')

    compare_inner_gtoplevelsof -double1,                 `options' tol(`tol')
    compare_inner_gtoplevelsof double1 -double2,         `options' tol(`tol')
    compare_inner_gtoplevelsof double1 -double2 double3, `options' tol(`tol')

    compare_inner_gtoplevelsof -int1,           `options' tol(`tol')
    compare_inner_gtoplevelsof int1 -int2,      `options' tol(`tol')
    compare_inner_gtoplevelsof int1 int2  int3, `options' tol(`tol')

    compare_inner_gtoplevelsof -int1 -str_32 -double1,                                         `options' tol(`tol')
    compare_inner_gtoplevelsof int1 -str_32 double1 -int2 str_12 -double2,                     `options' tol(`tol')
    compare_inner_gtoplevelsof int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options' tol(`tol')
end

capture program drop compare_inner_gtoplevelsof
program compare_inner_gtoplevelsof
    syntax [anything], [tol(real 1e-6) *]

    local N = trim("`: di %15.0gc _N'")
    local hlen = 35 + length("`anything'") + length("`N'")
    di as txt _n(2) "Checking contract. N = `N'; varlist = `anything'" _n(1) "{hline `hlen'}"

    preserve
        _compare_inner_gtoplevelsof `anything', `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_gtoplevelsof  `anything' in `from' / `to', `options' tol(`tol')
    restore, preserve
        _compare_inner_gtoplevelsof `anything' if random2 > 0, `options' tol(`tol')
    restore, preserve
        local in1 = ceil((0.00 + 0.25 * runiform()) * `=_N')
        local in2 = ceil((0.75 + 0.25 * runiform()) * `=_N')
        local from = cond(`in1' < `in2', `in1', `in2')
        local to   = cond(`in1' > `in2', `in1', `in2')
        _compare_inner_gtoplevelsof `anything' if random2 < 0 in `from' / `to', `options' tol(`tol')
    restore
end

capture program drop _compare_inner_gtoplevelsof
program _compare_inner_gtoplevelsof
    syntax [anything] [if] [in], [tol(real 1e-6) *]

    * cf(Cum) p(Pct) cp(PctCum)
    local opts freq(N)
    preserve
        qui {
            `noisily' gcontract `anything' `if' `in', `opts'
            local r_N = `r(N)'
            hashsort -N `anything'
            keep in 1/10
            set obs 11
            gen byte ID = 1
            replace ID  = 3 in 11
            gen long ix = _n
            gen long Cum = sum(N)
            gen double Pct = 100 * N / `r_N'
            gen double PctCum = 100 * Cum / `r_N'
            replace Pct       = 100 - PctCum[10] in 11
            replace PctCum    = 100 in 11
            replace N         = `r_N' - Cum[10] in 11
            replace Cum       = `r_N' in 11
        }
        tempfile fg
        qui save `fg'
    restore

    tempname gmat
    preserve
        qui {
            `noisily' gtoplevelsof `anything' `if' `in', mat(`gmat')
            clear
            svmat `gmat', names(col)
            gen long ix = _n
        }
        tempfile fc
        qui save `fc'
    restore

    preserve
    use `fc', clear
        local bad_any = 0
        local bad `anything'
        local bad: subinstr local bad "-" "", all
        local bad: subinstr local bad "+" "", all
        foreach var in N Cum Pct PctCum {
            rename `var' c_`var'
        }
        qui merge 1:1 ix using `fg', assert(3)
        foreach var in N Cum Pct PctCum {
            qui count if ( (abs(`var' - c_`var') > `tol') & (`var' != c_`var'))
            if ( `r(N)' > 0 ) {
                gen bad_`var' = abs(`var' - c_`var') * (`var' != c_`var')
                local bad `bad' *`var'
                di "    `var' has `:di r(N)' mismatches".
                local bad_any = 1
                order *`var'
            }
        }
        if ( `bad_any' ) {
            if ( "`if'`in'" == "" ) {
                di "    compare_gtoplevelsof_gcontract (failed): full range, `anything'"
            }
            else if ( "`if'`in'" != "" ) {
                di "    compare_gtoplevelsof_gcontract (failed): [`if' `in'], `anything'"
            }
            order `bad'
            egen bad_any = rowmax(bad_*)
            l `bad' if bad_any
            sum bad_*
            desc
            exit 9
        }
        else {
            if ( "`if'`in'" == "" ) {
                di "    compare_gtoplevelsof_gcontract (passed): full range, gcontract results equal to contract (tol = `tol')"
            }
            else if ( "`if'`in'" != "" ) {
                di "    compare_gtoplevelsof_gcontract (passed): [`if' `in'], gcontract results equal to contract (tol = `tol')"
            }
        }
    restore
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_toplevelsof
program bench_toplevelsof
    syntax, [tol(real 1e-6) bench(real 1) n(int 1000) NOIsily *]

    qui gen_data, n(`n') random(1) double
    qui expand `=100 * `bench''
    qui hashsort random1

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    di as txt _n(1)
    di as txt "Benchmark toplevelsof vs contract (unsorted), obs = `N', J = `J' (in seconds)"
    di as txt "    gcontract | gtoplevelsof | ratio (c/t) | varlist"
    di as txt "    --------- | ------------ | ----------- | -------"

    versus_toplevelsof str_12,              `options'
    versus_toplevelsof str_12 str_32,       `options'
    versus_toplevelsof str_12 str_32 str_4, `options'

    versus_toplevelsof double1,                 `options'
    versus_toplevelsof double1 double2,         `options'
    versus_toplevelsof double1 double2 double3, `options'

    versus_toplevelsof int1,           `options'
    versus_toplevelsof int1 int2,      `options'
    versus_toplevelsof int1 int2 int3, `options'

    versus_toplevelsof int1 str_32 double1,                                        `options'
    versus_toplevelsof int1 str_32 double1 int2 str_12 double2,                    `options'
    versus_toplevelsof int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    di as txt _n(1)
    di as txt "Benchmark toplevelsof vs contract (plus preserve, sort, keep, restore), obs = `N', J = `J' (in seconds)"
    di as txt "    gcontract | gtoplevelsof | ratio (c/t) | varlist"
    di as txt "    --------- | ------------ | ----------- | -------"

    versus_toplevelsof str_12,              `options' sorted
    versus_toplevelsof str_12 str_32,       `options' sorted
    versus_toplevelsof str_12 str_32 str_4, `options' sorted

    versus_toplevelsof double1,                 `options' sorted
    versus_toplevelsof double1 double2,         `options' sorted
    versus_toplevelsof double1 double2 double3, `options' sorted

    versus_toplevelsof int1,           `options' sorted
    versus_toplevelsof int1 int2,      `options' sorted
    versus_toplevelsof int1 int2 int3, `options' sorted

    versus_toplevelsof int1 str_32 double1,                                        `options' sorted
    versus_toplevelsof int1 str_32 double1 int2 str_12 double2,                    `options' sorted
    versus_toplevelsof int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options' sorted

    di _n(1) "{hline 80}" _n(1) "bench_toplevelsof, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_toplevelsof
program versus_toplevelsof, rclass
    syntax [anything], [sorted *]

    local stats       ""
    local percentiles ""

    local opts freq(freq) cf(cf) p(p) cp(cp)

    if ( "`sorted'" == "" ) {
    preserve
        timer clear
        timer on 42
        qui gcontract `anything' `if' `in', `opts'
        timer off 42
        qui timer list
        local time_contract = r(t42)
    restore
    }
    else {
        timer clear
        timer on 42
        qui {
            preserve
            gcontract `anything' `if' `in', `opts'
            hashsort -freq `anything'
            keep in 1/10
            restore
        }
        timer off 42
        qui timer list
        local time_contract = r(t42)
    }

    timer clear
    timer on 43
    qui gtoplevelsof `anything' `if' `in'
    timer off 43
    qui timer list
    local time_gcontract = r(t43)

    local rs = `time_contract'  / `time_gcontract'
    di as txt "    `:di %9.3g `time_contract'' | `:di %12.3g `time_gcontract'' | `:di %11.3g `rs'' | `anything'"
end
capture program drop checks_isid
program checks_isid
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_isid, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(5000)
    qui expand 2
    gen long ix  = _n
    gen byte ind = 0

    checks_inner_isid str_12,              `options'
    checks_inner_isid str_12 str_32,       `options'
    checks_inner_isid str_12 str_32 str_4, `options'

    checks_inner_isid double1,                 `options'
    checks_inner_isid double1 double2,         `options'
    checks_inner_isid double1 double2 double3, `options'

    checks_inner_isid int1,           `options'
    checks_inner_isid int1 int2,      `options'
    checks_inner_isid int1 int2 int3, `options'

    checks_inner_isid int1 str_32 double1,                                        `options'
    checks_inner_isid int1 str_32 double1 int2 str_12 double2,                    `options'
    checks_inner_isid int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    clear
    gen x = 1
    cap gisid x
    assert _rc == 0

    clear
    set obs 4
    gen x = 1
    gen y = _n
    gen z = _n
    replace y = 1 in 1/2
    replace x = 2 in 3/4
    gisid x y z, v

    replace y = x
    replace z = 1 in 1/2
    cap noi gisid x y z, v
    assert _rc == 459
end

capture program drop checks_inner_isid
program checks_inner_isid
    syntax varlist, [*]
    cap gisid `varlist', `options' v bench missok
    assert _rc == 459

    cap gisid `varlist' in 1, `options' missok
    assert _rc == 0

    cap gisid `varlist' if _n == 1, `options' missok
    assert _rc == 0

    cap gisid `varlist' if _n < 10 in 5, `options' missok
    assert _rc == 0

    cap gisid ix `varlist', `options' v bench missok
    assert _rc == 0

    preserve
    sort `varlist'
    cap gisid `varlist' ix, `options' v bench missok
    assert _rc == 0

    qui replace ix  = _n
    qui replace ix  = 1 in 1/2
    qui replace ind = 1 in 3/4
    cap gisid  ind ix `varlist', `options' v bench missok
    assert _rc == 459
    restore
end

***********************************************************************
*                               Compare                               *
***********************************************************************

capture program drop compare_isid
program compare_isid
    syntax, [tol(real 1e-6) NOIsily *]

    qui `noisily' gen_data, n(1000)
    qui expand 100

    local N    = trim("`: di %15.0gc _N'")
    local hlen = 20 + length("`options'") + length("`N'")
    di _n(1) "{hline 80}" _n(1) "compare_isid, N = `N', `options'" _n(1) "{hline 80}" _n(1)

    compare_inner_isid str_12,              `options'
    compare_inner_isid str_12 str_32,       `options'
    compare_inner_isid str_12 str_32 str_4, `options'

    compare_inner_isid double1,                 `options'
    compare_inner_isid double1 double2,         `options'
    compare_inner_isid double1 double2 double3, `options'

    compare_inner_isid int1,           `options'
    compare_inner_isid int1 int2,      `options'
    compare_inner_isid int1 int2 int3, `options'

    compare_inner_isid int1 str_32 double1,                                        `options'
    compare_inner_isid int1 str_32 double1 int2 str_12 double2,                    `options'
    compare_inner_isid int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'
end

capture program drop compare_inner_isid
program compare_inner_isid
    syntax varlist, [*]

    tempvar rsort ix
    gen `rsort' = runiform()
    sort `rsort'
    gen long `ix' = _n

    cap isid `varlist', missok
    local rc_isid = _rc
    cap gisid `varlist', missok `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by( `varlist')

    * make sure sorted check gives same result
    hashsort `varlist'
    cap gisid `varlist', missok `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by([sorted] `varlist')

    cap isid `ix' `varlist', missok
    local rc_isid = _rc
    cap gisid `ix' `varlist', missok `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by( ix `varlist')

    * make sure sorted check gives same result
    hashsort `ix' `varlist'
    cap gisid `ix' `varlist', missok `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by([sorted] ix `varlist')

    cap isid `rsort' `varlist', missok
    local rc_isid = _rc
    cap gisid `rsort' `varlist', missok `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by( rsort `varlist')

    * make sure sorted check gives same result
    hashsort rsort `varlist'
    cap isid `rsort' `varlist', missok
    local rc_isid = _rc
    cap gisid `rsort' `varlist', missok `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by([sorted] rsort `varlist')

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    qui replace `ix' = `=_N / 2' if _n > `=_N / 2'
    cap isid `ix'
    local rc_isid = _rc
    cap gisid `ix', `options'
    local rc_gisid = _rc
    check_rc `rc_isid' `rc_gisid' , by( ix)

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    preserve
        qui keep in 100 / `=ceil(`=_N / 2')'
        cap isid `ix' `varlist', missok
        local rc_isid = _rc
    restore
    cap gisid `ix' `varlist' in 100 / `=ceil(`=_N / 2')', missok `options'
    local rc_gisid = _rc
    check_rc  `rc_isid' `rc_gisid' , by( ix `varlist' in 100 / `=ceil(`=_N / 2')')

    preserve
        qui keep in `=ceil(`=_N / 2')' / `=_N'
        cap isid `ix' `varlist', missok
        local rc_isid = _rc
    restore
    cap gisid `ix' `varlist' in `=ceil(`=_N / 2')' / `=_N', missok `options'
    local rc_gisid = _rc
    check_rc  `rc_isid' `rc_gisid' , by( ix `varlist' in `=ceil(`=_N / 2')' / `=_N')

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    preserve
        qui keep if _n < `=_N / 2'
        cap isid `ix' `varlist', missok
        local rc_isid = _rc
    restore
    cap gisid `ix' `varlist' if _n < `=_N / 2', missok
    local rc_gisid = _rc
    check_rc  `rc_isid' `rc_gisid' , by( ix `varlist' if _n < `=_N / 2')

    preserve
        qui keep if _n > `=_N / 2'
        cap isid `ix' `varlist', missok
        local rc_isid = _rc
    restore
    cap gisid `ix' `varlist' if _n > `=_N / 2', missok `options'
    local rc_gisid = _rc
    check_rc  `rc_isid' `rc_gisid' , by( ix `varlist' if _n > `=_N / 2')

    * ---------------------------------------------------------------------
    * ---------------------------------------------------------------------

    qui replace `ix' = 100 in 1 / 100

    preserve
        qui keep if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')'
        cap isid `ix' `varlist', missok
        local rc_isid = _rc
    restore
    cap gisid `ix' `varlist' if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')', missok `options'
    local rc_gisid = _rc
    check_rc  `rc_isid' `rc_gisid' , by( ix `varlist' if _n < `=_N / 4' in 100 / `=ceil(`=_N / 2')')

    preserve
        qui keep if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N'
        cap isid `ix' `varlist', missok
        local rc_isid = _rc
    restore
    cap gisid `ix' `varlist' if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N', missok
    local rc_gisid = _rc
    check_rc  `rc_isid' `rc_gisid' , by( ix `varlist' if _n > `=_N / 4' in `=ceil(`=_N / 1.5')' / `=_N')

    di _n(1)
end

capture program drop check_rc
program check_rc
    syntax anything, by(str)

    tokenize `anything'
    local rc_isid  `1'
    local rc_gisid `2'

    if ( `rc_isid' != `rc_gisid' ) {
        if ( `rc_isid' & (`rc_gisid' == 0) ) {
            di as err "    compare_isid (failed): gisid `by' was an id but isid returned error r(`rc_isid')"
            exit `rc_isid'
        }
        else if ( (`rc_isid' == 0) & `rc_gisid' ) {
            di as err "    compare_isid (failed): isid `by' was an id but gisid returned error r(`rc_gisid')"
            exit `rc_gisigd'
        }
        else {
            di as err "    compare_isid (failed): `by' was not an id but isid and gisid returned different errors r(`rc_isid') vs r(`rc_gisid')"
            exit `rc_gisid'
        }
    }
    else {
        if ( _rc ) {
            di as txt "    compare_isid (passed): `by' was not an id"
        }
        else {
            di as txt "    compare_isid (passed): `by' was an id"
        }
    }
end

***********************************************************************
*                             Benchmarks                              *
***********************************************************************

capture program drop bench_isid
program bench_isid
    syntax, [tol(real 1e-6) bench(int 1) n(int 1000) NOIsily *]

    qui `noisily' gen_data, n(`n')
    qui expand `=100 * `bench''
    qui gen rsort = rnormal()
    qui sort rsort

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    di as txt _n(1)
    di as txt "Benchmark vs isid, obs = `N', all calls include an index to ensure uniqueness (in seconds)"
    di as txt "     isid | fisid | gisid | ratio (i/g) | ratio (f/g) | varlist"
    di as txt "     ---- | ----- | ----- | ----------- | ----------- | -------"

    versus_isid str_12,              `options' fisid unique
    versus_isid str_12 str_32,       `options' fisid unique
    versus_isid str_12 str_32 str_4, `options' fisid unique

    versus_isid double1,                 `options' fisid unique
    versus_isid double1 double2,         `options' fisid unique
    versus_isid double1 double2 double3, `options' fisid unique

    versus_isid int1,           `options' fisid unique
    versus_isid int1 int2,      `options' fisid unique
    versus_isid int1 int2 int3, `options' fisid unique

    versus_isid int1 str_32 double1,                                        unique `options'
    versus_isid int1 str_32 double1 int2 str_12 double2,                    unique `options'
    versus_isid int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, unique `options'

    di as txt _n(1)
    di as txt "Benchmark vs isid, obs = `N', J = `J' (in seconds)"
    di as txt "     isid | fisid | gisid | ratio (i/g) | ratio (f/g) | varlist"
    di as txt "     ---- | ----- | ----- | ----------- | ----------- | -------"

    versus_isid str_12,              `options' fisid
    versus_isid str_12 str_32,       `options' fisid
    versus_isid str_12 str_32 str_4, `options' fisid

    versus_isid double1,                 `options' fisid
    versus_isid double1 double2,         `options' fisid
    versus_isid double1 double2 double3, `options' fisid

    versus_isid int1,           `options' fisid
    versus_isid int1 int2,      `options' fisid
    versus_isid int1 int2 int3, `options' fisid

    versus_isid int1 str_32 double1,                                        `options'
    versus_isid int1 str_32 double1 int2 str_12 double2,                    `options'
    versus_isid int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    di as txt _n(1) "{hline 80}" _n(1) "bench_isid, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop versus_isid
program versus_isid, rclass
    syntax varlist, [fisid unique *]
    if ( "`unique'" == "unique" ) {
        tempvar ix
        gen `ix' = `=_N' - _n
        if ( strpos("`varlist'", "str") ) qui tostring `ix', replace
    }

    preserve
        timer clear
        timer on 42
        cap isid `varlist' `ix', missok
        assert inlist(_rc, 0, 459)
        timer off 42
        qui timer list
        local time_isid = r(t42)
    restore

    preserve
        timer clear
        timer on 43
        cap gisid `varlist' `ix', `options' missok
        assert inlist(_rc, 0, 459)
        timer off 43
        qui timer list
        local time_gisid = r(t43)
    restore

    if ( "`fisid'" == "fisid" ) {
    preserve
        timer clear
        timer on 44
        cap fisid `varlist' `ix', missok
        assert inlist(_rc, 0, 459)
        timer off 44
        qui timer list
        local time_fisid = r(t44)
    restore
    }
    else {
        local time_fisid = .
    }

    local rs = `time_isid'  / `time_gisid'
    local rf = `time_fisid' / `time_gisid'
    di as txt "    `:di %5.3g `time_isid'' | `:di %5.3g `time_fisid'' | `:di %5.3g `time_gisid'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `varlist'"
end
capture program drop checks_hashsort
program checks_hashsort
    syntax, [tol(real 1e-6) NOIsily *]
    di _n(1) "{hline 80}" _n(1) "checks_hashsort, `options'" _n(1) "{hline 80}" _n(1)

    qui `noisily' gen_data, n(5000)
    qui expand 2
    gen long ix = _n

    checks_inner_hashsort -str_12,              `options'
    checks_inner_hashsort str_12 -str_32,       `options'
    checks_inner_hashsort str_12 -str_32 str_4, `options'

    checks_inner_hashsort -double1,                 `options'
    checks_inner_hashsort double1 -double2,         `options'
    checks_inner_hashsort double1 -double2 double3, `options'

    checks_inner_hashsort -int1,           `options'
    checks_inner_hashsort int1 -int2,      `options'
    checks_inner_hashsort int1 -int2 int3, `options'

    checks_inner_hashsort -int1 -str_32 -double1,                                         `options'
    checks_inner_hashsort int1 -str_32 double1 -int2 str_12 -double2,                     `options'
    checks_inner_hashsort int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options'

    sysuse auto, clear
    gen idx = _n
    hashsort -foreign rep78 make -mpg, `options'
    hashsort idx,                      `options'
    hashsort -foreign rep78,           `options'
    hashsort idx,                      `options'
    hashsort foreign rep78 mpg,        `options'
    hashsort idx,                      `options' v bench
end

capture program drop checks_inner_hashsort
program checks_inner_hashsort
    syntax anything, [*]
    tempvar ix
    hashsort `anything', `options' gen(`ix')
    hashsort `: subinstr local anything "-" "", all', `options'
    hashsort ix, `options'
end

capture program drop bench_hashsort
program bench_hashsort
    compare_hashsort `0'
end

capture program drop compare_hashsort
program compare_hashsort
    syntax, [tol(real 1e-6) NOIsily bench(int 1) n(int 1000) *]

    cap gen_data, n(`n')
    qui expand 10 * `bench'
    qui gen rsort = rnormal()
    qui sort rsort

    local N = trim("`: di %15.0gc _N'")
    local J = trim("`: di %15.0gc `n''")

    di _n(1)
    di "Benchmark vs gsort, obs = `N', J = `J' (in seconds; datasets are compared via {opt cf})"
    di "    gsort | hashsort | ratio (g/h) | varlist"
    di "    ----- | -------- | ----------- | -------"

    compare_gsort -str_12,              `options'
    compare_gsort str_12 -str_32,       `options'
    compare_gsort str_12 -str_32 str_4, `options'

    compare_gsort -double1,                 `options'
    compare_gsort double1 -double2,         `options'
    compare_gsort double1 -double2 double3, `options'

    compare_gsort -int1,           `options'
    compare_gsort int1 -int2,      `options'
    compare_gsort int1 -int2 int3, `options'

    compare_gsort -int1 -str_32 -double1,                                         `options'
    compare_gsort int1 -str_32 double1 -int2 str_12 -double2,                     `options'
    compare_gsort int1 -str_32 double1 -int2 str_12 -double2 int3 -str_4 double3, `options'

    qui expand 10
    local N = trim("`: di %15.0gc _N'")

    di _n(1)
    di "Benchmark vs sort, obs = `N', J = `J' (in seconds; datasets are compared via {opt cf})"
    di "     sort | fsort | hashsort | ratio (s/h) | ratio (f/h) | varlist"
    di "     ---- | ----- | -------- | ----------- | ----------- | -------"

    compare_sort str_12,              `options' fsort
    compare_sort str_12 str_32,       `options' fsort
    compare_sort str_12 str_32 str_4, `options' fsort

    compare_sort double1,                 `options' fsort
    compare_sort double1 double2,         `options' fsort
    compare_sort double1 double2 double3, `options' fsort

    compare_sort int1,           `options' fsort
    compare_sort int1 int2,      `options' fsort
    compare_sort int1 int2 int3, `options' fsort

    compare_sort int1 str_32 double1,                                        `options'
    compare_sort int1 str_32 double1 int2 str_12 double2,                    `options'
    compare_sort int1 str_32 double1 int2 str_12 double2 int3 str_4 double3, `options'

    di _n(1) "{hline 80}" _n(1) "compare_hashsort, `options'" _n(1) "{hline 80}" _n(1)
end

capture program drop compare_sort
program compare_sort, rclass
    syntax varlist, [fsort benchmode *]
    local rc = 0

    timer clear
    preserve
        timer on 42
        sort `varlist' , stable
        timer off 42
        tempfile file_sort
        qui save `file_sort'
    restore
    qui timer list
    local time_sort = r(t42)

    timer clear
    preserve
        timer on 43
        qui hashsort `varlist', `options'
        timer off 43
        cap noi cf * using `file_sort'
        if ( _rc ) {
            qui ds *
            local memvars `r(varlist)' 
            local firstvar: word 1 of `varlist'
            local compvars: list memvars - firstvar
            if ( "`compvars'" != "" ) {
                cf `compvars' using `file_sort'
            }
            keep `firstvar'
            tempfile file_first
            qui save `file_first'

            use `firstvar' using `file_sort', clear
            rename `firstvar' c_`firstvar'
            qui merge 1:1 _n using `file_first'
            cap noi assert (`firstvar' == c_`firstvar') | (abs(`firstvar' - c_`firstvar') < 1e-15)
            if ( _rc ) {
                local rc = _rc
                di as err "hashsort gave different sort order to sort"
            }
            else {
                if ("`benchmode'" == "") di as txt "    hashsort same as sort but sortpreserve trick caused some loss of precision (< 1e-15)"
            }
        }

        * Make sure already sorted check is OK
        qui gen byte one = 1
        hashsort one `varlist', `options'
        qui drop one
        cap cf * using `file_sort'
        if ( _rc ) {
            qui ds *
            local memvars `r(varlist)' 
            local firstvar: word 1 of `varlist'
            local compvars: list memvars - firstvar
            if ( "`compvars'" != "" ) {
                cf `compvars' using `file_sort'
            }
            keep `firstvar'
            tempfile file_one
            qui save `file_one'

            use `firstvar' using `file_sort', clear
            rename `firstvar' c_`firstvar'
            qui merge 1:1 _n using `file_one'
            cap noi assert (`firstvar' == c_`firstvar') | (abs(`firstvar' - c_`firstvar') < 1e-15)
            if ( _rc ) {
                local rc = _rc
                di as err "hashsort gave different sort order to sort"
            }
            else {
                if ("`benchmode'" == "") di as txt "    hashsort same as sort but sortpreserve trick caused some loss of precision (< 1e-15)"
            }
        }
    restore
    qui timer list
    local time_hashsort = r(t43)

    if ( `rc' ) exit `rc'

    if ( "`fsort'" == "fsort" ) {
        timer clear
        preserve
            timer on 44
            qui fsort `varlist'
            timer off 44
            cf * using `file_sort'
        restore
        qui timer list
        local time_fsort = r(t44)
    }
    else {
        local time_fsort = .
    }

    local rs = `time_sort'  / `time_hashsort'
    local rf = `time_fsort' / `time_hashsort'
    di "    `:di %5.3g `time_sort'' | `:di %5.3g `time_fsort'' | `:di %8.3g `time_hashsort'' | `:di %11.3g `rs'' | `:di %11.3g `rf'' | `varlist'"
end

capture program drop compare_gsort
program compare_gsort, rclass
    syntax anything, [benchmode *]
    tempvar ix
    gen long `ix' = _n

    timer clear
    preserve
        timer on 42
        gsort `anything', mfirst
        timer off 42
        tempfile file_sort
        qui save `file_sort'
    restore
    qui timer list
    local time_sort = r(t42)

    timer clear
    preserve
        timer on 43
        qui hashsort `anything', `options'
        timer off 43
        cf `:di subinstr("`anything'", "-", "", .)' using `file_sort'
    restore
    qui timer list
    local time_hashsort = r(t43)

    local rs = `time_sort'  / `time_hashsort'
    di "    `:di %5.3g `time_sort'' | `:di %8.3g `time_hashsort'' | `:di %11.3g `rs'' | `anything'"
end

* ---------------------------------------------------------------------
* Run the things

main, dependencies basic_checks comparisons bench_test
