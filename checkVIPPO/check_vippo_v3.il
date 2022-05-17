;load "check_vippo_v3.il"

axlCmdRegister( "check_vippo" 'main_check_vippo)

originalActiveLayer = list()
lstRedundantVIPPO = list()
lstTestViaVIPPO = list()
lstViaInPad_TOP = list()
lstViaInPad_BOTTOM = list()
lstThermalVia_TOP = list()
lstThermalVia_BOTTOM = list()
lstInvalidVia_TOP = list()
lstInvalidVia_BOTTOM = list()
lstPinInPad_TOP = list()
lstPinInPad_BOTTOM = list()
lstErrorRadius_TOP = list()
lstErrorRadius_BOTTOM = list()
lstViaUnderBody_TOP = list()
lstViaUnderBody_BOTTOM = list()
defineViaType = list("TEST_VIA" "VIPPO_TOP" "VIPPO_BOTTOM" "THERMAL_VIA_TOP" "THERMAL_VIA_BOTTOM")

procedure( main_check_vippo()
    let( (allFilm artworkVIPPOFilm artworkVIPPO_TOPLayer artworkVIPPO_BOTTOMLayer allVIPPO_Shape _tmp_via _tmp_redundant_vippo allVias startTimeRunScript endTimeRunScript totalSecond totalMinute
          check_testvia_top check_testvia_bottom check_vippo_top check_vippo_bottom check_thermal_via_top check_thermal_via_bottom check_pin_in_pad_top check_pin_in_pad_bottom allPin_TOP allPin_BOTTOM 
          pip_up_left_point pip_down_right_point pip_point)
        axlUIWPrint(nil "Loading check_vippo V3.0\n")
        startTimeRunScript = vpcGetCurrentTime()

        originalActiveLayer = list()
        lstRedundantVIPPO = list()
        lstTestViaVIPPO = list()
        lstViaInPad_TOP = list()
        lstViaInPad_BOTTOM = list()
        lstThermalVia_TOP = list()
        lstThermalVia_BOTTOM = list()
        lstInvalidVia_TOP = list()
        lstInvalidVia_BOTTOM = list()
        lstErrorRadius_TOP = list()
        lstErrorRadius_BOTTOM = list()
        lstPinInPad_TOP = list()
        lstPinInPad_BOTTOM = list()

        check_testvia_top = ncons(t) 
        check_testvia_bottom = ncons(t)
        check_vippo_top = ncons(t)
        check_vippo_bottom = ncons(t)
        check_thermal_via_top = ncons(t)
        check_thermal_via_bottom = ncons(t)

        lstViaUnderBody_TOP = list()
        lstViaUnderBody_BOTTOM = list()

        originalActiveLayer = vpcGetAllVisibleLayer()

        ;Find VIPPO_FILM
        allFilm = axlGetParam("artwork")->groupMembers
        artworkVIPPOFilm = list()

        foreach(_f allFilm
            when( nindex(_f "VIPPO") != nil 
                artworkVIPPOFilm = cons(axlGetParam(sprintf(nil "artwork:%s" _f)) artworkVIPPOFilm)
            )
        )        

        if( length(artworkVIPPOFilm) != 0 then
            foreach(_art artworkVIPPOFilm
                foreach(_class _art->groupMembers
                    when( nindex(_class "TOP") != nil
                        artworkVIPPO_TOPLayer = _class
                    )
                    when( nindex(_class "BOTTOM") != nil
                        artworkVIPPO_BOTTOMLayer = _class
                    )
                )
            ) 
            
            /* Check redundant VIPPO */
            ;Invisible all active layer
            foreach(_layer originalActiveLayer
                axlVisibleLayer(_layer nil)
            )
            axlVisibleLayer(artworkVIPPO_TOPLayer t)
            axlVisibleLayer(artworkVIPPO_BOTTOMLayer t)
            axlSetFindFilter(?enabled (list "SHAPES") ?onButtons (list "SHAPES"))
            axlAddSelectAll()
            allVIPPO_Shape = axlGetSelSet()

            axlVisibleLayer("VIA CLASS/TOP" t)
            axlVisibleLayer("PIN/TOP" t)
            axlVisibleLayer("VIA CLASS/BOTTOM" t)
            axlVisibleLayer("PIN/BOTTOM" t)

            axlSetFindFilter(?enabled (list "NOALL" "VIAS" "PINS") ?onButtons (list "NOALL" "VIAS" "PINS"))

            ;printf("Check redundant VIPPO Shapes\n") 
            foreach(_vs allVIPPO_Shape                
                axlSingleSelectBox(_vs->bBox)
                _tmp_via = axlGetSelSet()
                _tmp_redundant_vippo = nil
                if(length(_tmp_via) != 0 then
                    foreach(_tmp _tmp_via      
                        when((_tmp->objType == "via") 
                            when((axlGeoEqual(xCoord(_tmp->xy) xCoord(car(_vs->segments)->xy)) == nil) || (axlGeoEqual(yCoord(_tmp->xy) yCoord(car(_vs->segments)->xy)) == nil) || (_tmp->isThrough == nil)
                                ;printf("%f : %f\n" xCoord(car(_vs->segments)->xy) yCoord(car(_vs->segments)->xy)) 
                                _tmp_redundant_vippo = _vs
                            )
                        )
                        when( ((_tmp->objType == "pin") && (_tmp->isThrough == t))
                            when((axlGeoEqual(xCoord(_tmp->xy) xCoord(car(_vs->segments)->xy)) == nil) || (axlGeoEqual(yCoord(_tmp->xy) yCoord(car(_vs->segments)->xy)) == nil)
                                ;printf("%f : %f\n" xCoord(car(_vs->segments)->xy) yCoord(car(_vs->segments)->xy)) 
                                _tmp_redundant_vippo = _vs
                            )
                        )                                          
                    )
                else
                    _tmp_redundant_vippo = _vs
                    ;printf("0-> %f : %f\n" xCoord(car(_vs->segments)->xy) yCoord(car(_vs->segments)->xy)) 
                )
                when(_tmp_redundant_vippo != nil lstRedundantVIPPO = cons(_tmp_redundant_vippo lstRedundantVIPPO) )               
            )

            ;printf("Check Vias do not contain VIPPO Shapes\n") 
            axlSetFindFilter(?enabled (list "NOALL" "VIAS") ?onButtons (list "NOALL" "VIAS"))
            axlAddSelectAll()
            allVias = axlGetSelSet()
            foreach(_via allVias
                when((_via->isThrough == t)
                    cond(
                        (vpcGetViaType(_via) == "TEST_VIA"
                            check_testvia_top = vpcCheckVIPPOShape_TOP(_via)
                            check_testvia_bottom = vpcCheckVIPPOShape_BOTTOM(_via)
                            when(!check_testvia_top->rPos || !check_testvia_bottom->rPos
                                lstTestViaVIPPO = cons(_via lstTestViaVIPPO)
                                ;printf("1-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy)) 
                            )
                            when(check_testvia_top->rRad == 1
                                lstErrorRadius_TOP = cons(_via lstErrorRadius_TOP)
                            ) 
                            when(check_testvia_bottom->rRad == 1
                                lstErrorRadius_BOTTOM = cons(_via lstErrorRadius_BOTTOM)
                            )
                        )
                        (vpcGetViaType(_via) == "VIPPO_TOP"
                            check_vippo_top = vpcCheckVIPPOShape_TOP(_via)
                            when(!check_vippo_top->rPos
                                lstViaInPad_TOP = cons(_via lstViaInPad_TOP)
                                ;printf("2-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy)) 
                            )
                            when(check_vippo_top->rRad == 1
                                lstErrorRadius_TOP = cons(_via lstErrorRadius_TOP)
                            ) 
                        )
                        (vpcGetViaType(_via) == "VIPPO_BOTTOM"
                            check_vippo_bottom = vpcCheckVIPPOShape_BOTTOM(_via)
                            when(!check_vippo_bottom->rPos
                                lstViaInPad_BOTTOM = cons(_via lstViaInPad_BOTTOM)
                                ;printf("3-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy))
                            )
                            when(check_vippo_bottom->rRad == 1
                                lstErrorRadius_BOTTOM = cons(_via lstErrorRadius_BOTTOM)
                            ) 
                        )
                        (vpcGetViaType(_via) == "THERMAL_VIA_TOP"
                            check_thermal_via_top = vpcCheckVIPPOShape_TOP(_via)
                            when(!check_thermal_via_top->rPos
                                lstThermalVia_TOP = cons(_via lstThermalVia_TOP)
                                ;printf("4-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy))
                            )
                            when(check_thermal_via_top->rRad == 1
                                lstErrorRadius_TOP = cons(_via lstErrorRadius_TOP)
                            ) 
                        )
                        (vpcGetViaType(_via) == "THERMAL_VIA_BOTTOM"
                            check_thermal_via_bottom = vpcCheckVIPPOShape_BOTTOM(_via)
                            when(!check_thermal_via_bottom->rPos
                                lstThermalVia_BOTTOM = cons(_via lstThermalVia_BOTTOM)
                                ;printf("5-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy))
                            )
                            when(check_thermal_via_bottom->rRad == 1
                                lstErrorRadius_BOTTOM = cons(_via lstErrorRadius_BOTTOM)
                            ) 
                        )
                        (t
                            when(vpcCheckVIPPOShape_TOP(_via)->rPos
                                lstInvalidVia_TOP = cons(_via lstInvalidVia_TOP)
                                ;printf("6-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy))
                            )
                            when(vpcCheckVIPPOShape_BOTTOM(_via)->rPos
                                lstInvalidVia_BOTTOM = cons(_via lstInvalidVia_BOTTOM)
                                ;printf("7-> %f : %f\n" xCoord(_via->xy) yCoord(_via->xy))
                            )
                        )
                    )            
                )                
            )

            axlClearSelSet()
            axlVisibleLayer("PIN/TOP" t)
            axlSetFindFilter(?enabled (list "NOALL" "PINS") ?onButtons (list "NOALL" "PINS"))
            axlAddSelectAll()
            allPin_TOP = axlGetSelSet()
            axlClearSelSet()
            foreach(_pin allPin_TOP
                when(_pin->name != nil
                    when((_pin->isThrough = t) && (nindex(_pin->name "VIA") != nil)      
                        axlClearSelSet()
                        axlSetFindFilter(?enabled (list "NOALL" "PINS") ?onButtons (list "NOALL" "PINS"))                                 
                        pip_up_left_point = list((xCoord(_pin->xy) - _pin->definition->drillDiameter/2.0) (yCoord(_pin->xy) - _pin->definition->drillDiameter/2.0))
                        pip_down_right_point = list((xCoord(_pin->xy) + _pin->definition->drillDiameter/2.0) (yCoord(_pin->xy) + _pin->definition->drillDiameter/2.0))
                        pip_point = list(pip_up_left_point pip_down_right_point)
                        axlSingleSelectBox(pip_point)
                    
                        when(length(axlGetSelSet()) >= 2
                            check_pin_in_pad_top = vpcCheckVIPPOShape_TOP(_pin)
                            when(!check_pin_in_pad_top->rPos
                                lstPinInPad_TOP = cons(_pin lstPinInPad_TOP)
                            )
                            when(check_pin_in_pad_top->rRad == 1
                                lstErrorRadius_TOP = cons(_pin lstErrorRadius_TOP)
                            ) 
                        )
                    )
                )
            )

            axlVisibleLayer("PIN/TOP" nil)
            axlVisibleLayer("PIN/BOTTOM" t)
            axlSetFindFilter(?enabled (list "NOALL" "PINS") ?onButtons (list "NOALL" "PINS"))
            axlAddSelectAll()
            allPin_BOTTOM = axlGetSelSet()            
            foreach(_pin allPin_BOTTOM
                when(_pin->name != nil
                    when((_pin->isThrough = t) && (nindex(_pin->name "VIA") != nil)
                        axlClearSelSet()
                        axlSetFindFilter(?enabled (list "NOALL" "PINS") ?onButtons (list "NOALL" "PINS"))
                        pip_up_left_point = list((xCoord(_pin->xy) - _pin->definition->drillDiameter/2.0) (yCoord(_pin->xy) - _pin->definition->drillDiameter/2.0))
                        pip_down_right_point = list((xCoord(_pin->xy) + _pin->definition->drillDiameter/2.0) (yCoord(_pin->xy) + _pin->definition->drillDiameter/2.0))
                        pip_point = list(pip_up_left_point pip_down_right_point)
                        axlSingleSelectBox(pip_point)

                        when(length(axlGetSelSet()) >= 2
                            check_pin_in_pad_bottom = vpcCheckVIPPOShape_BOTTOM(_pin)
                            when(!check_pin_in_pad_bottom->rPos
                                lstPinInPad_BOTTOM = cons(_pin lstPinInPad_BOTTOM)
                            )
                            when(check_pin_in_pad_bottom->rRad == 1
                                lstErrorRadius_BOTTOM = cons(_pin lstErrorRadius_BOTTOM)
                            ) 
                        )
                    )
                )
            )

            axlVisibleLayer("VIA CLASS/TOP" nil)
            axlVisibleLayer("PIN/TOP" nil)
            axlVisibleLayer("VIA CLASS/BOTTOM" nil)
            axlVisibleLayer("PIN/BOTTOM" nil)
            axlVisibleLayer(artworkVIPPO_TOPLayer t)
            axlVisibleLayer(artworkVIPPO_BOTTOMLayer t)
            ;Visible all active layer
            foreach(_layer originalActiveLayer
                axlVisibleLayer(_layer t)
            )
        else
            axlUIWPrint(nil "No VIPPO Found\n")
        )
        endTimeRunScript = vpcGetCurrentTime() 
        totalSecond = mod(((60 - startTimeRunScript->second) + endTimeRunScript->second) 60) 
        totalMinute = (endTimeRunScript->minute - startTimeRunScript->minute - 1) + ((60 - startTimeRunScript->second) + endTimeRunScript->second)/60
        axlUIWPrint(nil sprintf(nil "Time Run Script: %d(m):%d(s)" totalMinute totalSecond))
        vpcExportReport()
    )   
)

defun( vpcGetAllVisibleLayer () 
	let( (result lstActiveLayerName _tmpClassName _tmpSubclass)
        result = list()
        _tmpClassName = axlGetParam("paramLayerGroup")->groupMembers
        foreach(_class _tmpClassName
            _tmpSubclass = axlSubclasses(_class) 

            foreach(_sub _tmpSubclass
                when( axlIsVisibleLayer(sprintf(nil "%s/%s" _class _sub)) == t
                    result = cons( sprintf(nil "%s/%s" _class _sub) result)
                )
            )
        )
        result
	) ; let
) ; defun

defun( vpcCheckVIPPOShape_TOP ( _via) 
	let( (result vippo_shape _tmp_vippo)
        result = ncons(t)
        result->rPos = nil
        result->rRad = nil
        axlVisibleLayer(artworkVIPPO_TOPLayer t)
        axlVisibleLayer(artworkVIPPO_BOTTOMLayer nil)
        axlClearSelSet()
        axlSetFindFilter(?enabled (list "NOALL" "SHAPES") ?onButtons (list "NOALL" "SHAPES"))
        axlSingleSelectPoint(_via->xy)
        vippo_shape = axlGetSelSet()
        foreach( _tmp_vippo vippo_shape            
            when(nindex(_tmp_vippo->layer "TOP") != nil
                when((axlGeoEqual(xCoord(_via->xy) xCoord(car(_tmp_vippo->segments)->xy)) == t) && (axlGeoEqual(yCoord(_via->xy) yCoord(car(_tmp_vippo->segments)->xy)) == t)
                    result->rPos = t
                )              
                if((axlGeoEqual(car(_tmp_vippo->segments)->radius (_via->definition->drillDiameter/2.0)) == t) then
                    result->rRad = 2
                else
                    result->rRad = 1
                )        
            )
        )
        axlVisibleLayer(artworkVIPPO_TOPLayer nil)
        result
	) ; let
) ; defun

defun( vpcCheckVIPPOShape_BOTTOM ( _via) 
	let( (result vippo_shape _tmp_vippo)
        result = ncons(t)
        result->ePos = nil
        result->eRad = nil
        axlVisibleLayer(artworkVIPPO_TOPLayer nil)
        axlVisibleLayer(artworkVIPPO_BOTTOMLayer t)
        axlClearSelSet()
        axlSetFindFilter(?enabled (list "NOALL" "SHAPES") ?onButtons (list "NOALL" "SHAPES"))
        axlSingleSelectPoint(_via->xy)
        vippo_shape = axlGetSelSet()
        foreach( _tmp_vippo vippo_shape            
            when(nindex(_tmp_vippo->layer "BOTTOM") != nil
                when((axlGeoEqual(xCoord(_via->xy) xCoord(car(_tmp_vippo->segments)->xy)) == t) && (axlGeoEqual(yCoord(_via->xy) yCoord(car(_tmp_vippo->segments)->xy)) == t)
                    result->rPos = t
                )              
                if((axlGeoEqual(car(_tmp_vippo->segments)->radius (_via->definition->drillDiameter/2.0)) == t) then
                    result->rRad = 2
                else
                    result->rRad = 1
                )           
            )
        )
        axlVisibleLayer(artworkVIPPO_BOTTOMLayer nil)
        result
	) ; let
) ; defun

defun( vpcCheckViaInPad_TOP ( _via) 
	let( (result selected_pin box_selection up_left_point down_right_point selected_pin)
        result = nil
        axlVisibleLayer("PIN/TOP" t)
        axlVisibleLayer("PIN/BOTTOM" nil)
        axlClearSelSet()
        axlSetFindFilter(?enabled (list "NOALL" "PINS") ?onButtons (list "NOALL" "PINS"))
        up_left_point = list((xCoord(_via->xy) - _via->definition->drillDiameter/2.0) (yCoord(_via->xy) - _via->definition->drillDiameter/2.0))
        down_right_point = list((xCoord(_via->xy) + _via->definition->drillDiameter/2.0) (yCoord(_via->xy) + _via->definition->drillDiameter/2.0))
        box_selection = list(up_left_point down_right_point)
        axlSingleSelectBox(box_selection)
        selected_pin = axlGetSelSet()
        when(selected_pin != nil 
            foreach(_pin selected_pin
                when(length(_pin->component->pins) > 1 result = t)
            )
        )
        result
	) ; let
) ; defun

defun( vpcCheckViaInPad_BOTTOM ( _via) 
	let( (result selected_pin box_selection up_left_point down_right_point selected_pin)
        result = nil
        axlVisibleLayer("PIN/TOP" nil)
        axlVisibleLayer("PIN/BOTTOM" t)
        axlClearSelSet()
        axlSetFindFilter(?enabled (list "NOALL" "PINS") ?onButtons (list "NOALL" "PINS"))
        up_left_point = list((xCoord(_via->xy) - _via->definition->drillDiameter/2.0) (yCoord(_via->xy) - _via->definition->drillDiameter/2.0))
        down_right_point = list((xCoord(_via->xy) + _via->definition->drillDiameter/2.0) (yCoord(_via->xy) + _via->definition->drillDiameter/2.0))
        box_selection = list(up_left_point down_right_point)
        axlSingleSelectBox(box_selection)
        selected_pin = axlGetSelSet()
        when(selected_pin != nil 
            foreach(_pin selected_pin
                when(length(_pin->component->pins) > 1 result = t)
            )
        )
        result
	) ; let
) ; defun

defun( vpcCheckThermalVia_TOP ( _via) 
	let( (result selected_dfa body_chip down_left_body up_right_body lst_thermalvias)
        result = nil
        axlVisibleLayer(artworkVIPPO_TOPLayer nil)
        axlVisibleLayer(artworkVIPPO_BOTTOMLayer nil)
        axlVisibleLayer("VIA CLASS/TOP" nil)
        axlVisibleLayer("PIN/TOP" nil)
        axlVisibleLayer("VIA CLASS/BOTTOM" nil)
        axlVisibleLayer("PIN/BOTTOM" nil)
        axlVisibleLayer("PACKAGE GEOMETRY/DFA_BOUND_TOP" t)
        axlVisibleLayer("PACKAGE GEOMETRY/DFA_BOUND_BOTTOM" nil)        
        
        if( memq(_via lstViaUnderBody_TOP) != nil then
            result = t
        else
            axlClearSelSet()
            axlSetFindFilter(?enabled (list "NOALL" "SHAPES") ?onButtons (list "NOALL" "SHAPES"))
            axlSingleSelectPoint(_via->xy)
            selected_dfa = car(axlGetSelSet())
            when((selected_dfa != nil) && (selected_dfa->objType == "shape") && (nindex(selected_dfa->parent->name "QFN") != nil)            
                down_left_body = list((xCoord(car(selected_dfa->bBox)) + 40.0) (yCoord(car(selected_dfa->bBox)) + 40.0)) 
                up_right_body = list((xCoord(cadr(selected_dfa->bBox)) - 40.0) (yCoord(cadr(selected_dfa->bBox)) - 40.0))
                body_chip = list(down_left_body up_right_body)
                axlVisibleLayer("VIA CLASS/TOP" t)
                axlSetFindFilter(?enabled (list "NOALL" "VIAS") ?onButtons (list "NOALL" "VIAS"))
                axlSingleSelectBox(body_chip)
                lst_thermalvias = axlGetSelSet()
                lstViaUnderBody_TOP = cons(lst_thermalvias lstViaUnderBody_TOP)
                when(memq(_via lst_thermalvias) != nil
                    result = t                    
                )
            )
            axlVisibleLayer("PACKAGE GEOMETRY/DFA_BOUND_TOP" nil)
        )        
        result
	) ; let
) ; defun

defun( vpcCheckThermalVia_BOTTOM ( _via) 
	let( (result selected_dfa body_chip down_left_body up_right_body lst_thermalvias)
        result = nil
        axlVisibleLayer(artworkVIPPO_TOPLayer nil)
        axlVisibleLayer(artworkVIPPO_BOTTOMLayer nil)
        axlVisibleLayer("VIA CLASS/TOP" nil)
        axlVisibleLayer("PIN/TOP" nil)
        axlVisibleLayer("VIA CLASS/BOTTOM" nil)
        axlVisibleLayer("PIN/BOTTOM" nil)
        axlVisibleLayer("PACKAGE GEOMETRY/DFA_BOUND_TOP" nil)
        axlVisibleLayer("PACKAGE GEOMETRY/DFA_BOUND_BOTTOM" t)
        
        if( memq(_via lstViaUnderBody_BOTTOM) != nil then
            result = t
        else
            axlClearSelSet()
            axlSetFindFilter(?enabled (list "NOALL" "SHAPES") ?onButtons (list "NOALL" "SHAPES"))
            axlSingleSelectPoint(_via->xy)
            selected_dfa = car(axlGetSelSet())
            when((selected_dfa != nil) && (selected_dfa->objType == "shape") && (nindex(selected_dfa->parent->name "QFN") != nil)            
                down_left_body = list((xCoord(car(selected_dfa->bBox)) + 40.0) (yCoord(car(selected_dfa->bBox)) + 40.0)) 
                up_right_body = list((xCoord(cadr(selected_dfa->bBox)) - 40.0) (yCoord(cadr(selected_dfa->bBox)) - 40.0))
                body_chip = list(down_left_body up_right_body)
                axlVisibleLayer("VIA CLASS/BOTTOM" t)
                axlSetFindFilter(?enabled (list "NOALL" "VIAS") ?onButtons (list "NOALL" "VIAS"))
                axlSingleSelectBox(body_chip)
                lst_thermalvias = axlGetSelSet()
                lstViaUnderBody_BOTTOM = cons(lst_thermalvias lstViaUnderBody_BOTTOM)
                when(memq(_via lst_thermalvias) != nil
                    result = t                    
                )
            )
            axlVisibleLayer("PACKAGE GEOMETRY/DFA_BOUND_BOTTOM" nil)
        )     
        result
	) ; let
) ; defun

defun( vpcGetViaType ( _via) 
	let( (result)
        result = nil
        cond(
            ((_via->testPoint == "ETCH/BOTTOM") result = nth(0 defineViaType))
            (vpcCheckViaInPad_TOP(_via) result = nth(1 defineViaType))
            (vpcCheckViaInPad_BOTTOM(_via) result = nth(2 defineViaType))
            (vpcCheckThermalVia_TOP(_via) result = nth(3 defineViaType))
            (vpcCheckThermalVia_BOTTOM(_via) result = nth(4 defineViaType))
        )
        result
	) ; let
) ; defun

defun( vpcGetCurrentTime () 
	let( (result lstTime lstHMS)
        result = ncons(t)
        lstTime = parseString(getCurrentTime() " ")
        lstHMS = parseString(nth(2 lstTime) ":")
        result->hour = atoi(nth(0 lstHMS))
        result->minute = atoi(nth(1 lstHMS))
        result->second = atoi(nth(2 lstHMS))
        result
	) ; let
) ; defun

defun( vpcExportReport () 
	let( (report_file tmp_file report_port directory_file totalVIPPOErrors)
        rexCompile(".tmp$")
        tmp_file = axlTempFile()
        report_file =  rexReplace(tmp_file ".htm" 0)
	    report_port = outfile(report_file "w")
        fprintf(report_port, "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n")
        fprintf(report_port, "<html>\n")
        fprintf(report_port, "<head><title>VIPPO Error Report</title></head>\n")
        directory_file = axlOSSlash(strcat(simplifyFilename(axlCurrentDesign()) ".brd"))        
        fprintf(report_port, "<b><u>Design Name</u>&nbsp;%s</b><br>\n" directory_file)
        fprintf(report_port, "<b><u>Date</u>&nbsp;%s</b><br>\n" getCurrentTime())
        fprintf(report_port, "<BODY>\n")
        fprintf(report_port, "<table align=center border=1><caption><b><u>VIPPO Error Summary</u></b></caption>\n")
        
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td><b>VIPPO Error Type</b></td>\n")
        fprintf(report_port, "<td><b>VIPPO Error Count</b></td>\n")
        fprintf(report_port, "</tr>\n")     
        
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>Redundant VIPPO Shape</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" length(lstRedundantVIPPO))
        fprintf(report_port, "</tr>\n")
        
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>Test VIAs</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" length(lstTestViaVIPPO))
        fprintf(report_port, "</tr>\n")  
        
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>VIAs In Pad</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" (length(lstViaInPad_TOP) + length(lstViaInPad_BOTTOM)))
        fprintf(report_port, "</tr>\n")     
        
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>Thermal VIAs</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" (length(lstThermalVia_TOP) + length(lstThermalVia_BOTTOM)))
        fprintf(report_port, "</tr>\n")  

        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>Invalid VIAs</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" (length(lstInvalidVia_TOP) + length(lstInvalidVia_BOTTOM)))
        fprintf(report_port, "</tr>\n")  
        
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>Error Radius VIPPO Shape</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" (length(lstErrorRadius_TOP) + length(lstErrorRadius_BOTTOM)))
        fprintf(report_port, "</tr>\n")  

        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true>Pin In Pads</td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" (length(lstPinInPad_TOP) + length(lstPinInPad_BOTTOM)))
        fprintf(report_port, "</tr>\n")  
        
        totalVIPPOErrors = length(lstRedundantVIPPO) + length(lstTestViaVIPPO) + length(lstViaInPad_TOP) + length(lstViaInPad_BOTTOM) + length(lstThermalVia_TOP) + length(lstThermalVia_BOTTOM) + length(lstInvalidVia_TOP) + length(lstInvalidVia_BOTTOM) + length(lstErrorRadius_TOP) + length(lstErrorRadius_BOTTOM) + length(lstPinInPad_TOP) + length(lstPinInPad_BOTTOM)
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td nowrap=true><b>Total VIPPO Errors</b></td>\n")
        fprintf(report_port, "<td nowrap=true align=right>%d</td>\n" totalVIPPOErrors)
        fprintf(report_port, "</tr>\n")  

        fprintf(report_port, "</table>\n") 

        fprintf(report_port, "<BR>\n")
        fprintf(report_port, "<table align=center border=1><caption><b><u>Detailed VIPPO Errors</u></b></caption>\n")
        fprintf(report_port, "<tr>\n")
        fprintf(report_port, "<td><b>VIPPO Error Type</b></td>\n")
        fprintf(report_port, "<td><b>Error Location</b></td>\n")
        fprintf(report_port, "<td><b>Layer</b></td>\n")
        fprintf(report_port, "</tr>\n")
        foreach(_line lstRedundantVIPPO
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Redundant VIPPO Shape</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(car(_line->segments)->xy) yCoord(car(_line->segments)->xy) car(_line->segments)->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" _line->layer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstTestViaVIPPO
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Test VIAs</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_BOTTOMLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstViaInPad_TOP
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>VIAs In Pad</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_TOPLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstViaInPad_BOTTOM
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>VIAs In Pad</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_BOTTOMLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstThermalVia_TOP
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Thermal VIAs</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_TOPLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstThermalVia_BOTTOM
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Thermal VIAs</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_BOTTOMLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstInvalidVia_TOP
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Invalid VIAs</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_TOPLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstInvalidVia_BOTTOM
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Invalid VIAs</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_BOTTOMLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstErrorRadius_TOP
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Wrong Radius</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_TOPLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstErrorRadius_BOTTOM
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Wrong Radius</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_BOTTOMLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstPinInPad_TOP
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Pin In Pads</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_TOPLayer)
            fprintf(report_port, "</tr>\n")
        )
        foreach(_line lstPinInPad_BOTTOM
            fprintf(report_port, "<tr>\n")
            fprintf(report_port, "<td nowrap=true>Pin In Pads</td>\n")
            fprintf(report_port, "<td nowrap=true><a href=\"xprobe:xy: %f %f \">%L</a></td>\n" xCoord(_line->xy) yCoord(_line->xy) _line->xy)
            fprintf(report_port, "<td nowrap=true>%s</td>\n" artworkVIPPO_BOTTOMLayer)
            fprintf(report_port, "</tr>\n")
        )

        fprintf(report_port, "</table>\n")

        fprintf(report_port, "</BODY>\n")
        fprintf(report_port, "</HTML>\n")

        close(report_port)
        axlUIWExpose(axlUIViewFileCreate(report_file "VIPPO Error Report" nil))
        axlTempFileRemove(tmp_file)
        if(isFile(report_file)
        deleteFile(report_file)
    )
	) ; let
) ; defun


