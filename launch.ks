function myAltitude {
    list parts in partList.
    set lp to 0.//lowest part height
    set hp to 0.//hightest part height
    for p in partList{
        set cp to facing:vector * p:position.
        if cp < lp 
            set lp to cp.
        else if cp > hp	
            set hp to cp.
    }
    set height to hp - lp.
    
    if Ship:GeoPosition:TerrainHeight > 0{
	    set SurfaceHeight to Ship:GeoPosition:TerrainHeight.
    } else {
        set SurfaceHeight to 0.
    }

        return Ship:Altitude - SurfaceHeight - height - 150.// + 470.
}

SAS on.
RCS off.
clearscreen.
gear off.

LIST ENGINES IN booster_engines.

set runmode to 2.
set dist to 0.
set dist_2 to 0.
set M_2 to 0.
set a_r to 0.
set i to 0.
set SurfaceHeight to Ship:GeoPosition:TerrainHeight.

lock g to constant:g * body:mass / body:radius^2.


until runmode = 0{

	// Calculating burn height in flight
	if runmode = 2{
        //brakes on.

        
        RCS on.
        lock steering to lookdirup(heading(90,90):vector, ship:facing:topvector).
        set throttle to 0.
        set p to BODY:ATM:ALTITUDEPRESSURE(myAltitude()).
        
        set eng_ISP to 0.
        set eng_THR to 0.
        set i to 0.
        //set V to (2*g*myAltitude() + SHIP:VERTICALSPEED^2)^(1/2).
        
        FOR eng IN booster_engines{
            set i to i + 1.
        
            set eng_ISP to eng_ISP + eng:ISPAT(p).
            
            set eng_THR to eng_THR + eng:AVAILABLETHRUSTAT(p).
            
        }
        
        set M_2 to SHIP:MASS/( constant:E^(SHIP:VELOCITY:SURFACE:MAG / ((eng_ISP/i)  * 9.81) )).
        set a_r to ( (eng_THR)/ ((SHIP:MASS + M_2)/2) ).
        
        set a_r to a_r - g.
        
        set dist to (SHIP:VELOCITY:SURFACE:MAG^2)/ (2 * a_r).
        

        if (myAltitude() - dist) < 1{
            set runmode to 3.
        }
    }
    
    
    // Landing
    else if runmode = 3{
        print "Suicide burn" at (5, 1).
        set throttle to 1.
        if myAltitude() < 600{
            gear on.
        }
        
        if -15 < SHIP:VERTICALSPEED and SHIP:VERTICALSPEED < 15{
            set throttle to 0.
            set runmode to 4.
        }
    }
    
    else if runmode = 4{
        print "Hello Reddit" at (3, 23).
        wait 0.5.
        print "Hello Reddit" at (19, 23).
        wait 0.5.
        print "Hello Reddit" at (36, 23).
        print "/u/PyQt" at (40, 1).
        wait 10.
            
        set runmode to 0.
    }
    
    
    If throttle = 0 { 
      set STEERINGMANAGER:MAXSTOPPINGTIME to 5.
      set STEERINGMANAGER:PITCHPID:KD to 2.
      set STEERINGMANAGER:YAWPID:KD to 2.
    } else if throttle > 0 {
      set STEERINGMANAGER:MAXSTOPPINGTIME to 1.
      set STEERINGMANAGER:PITCHPID:KD to 1.
      set STEERINGMANAGER:YAWPID:KD to 1.
    }   
    
    
    print "RunMode       = " + runmode at (5, 3).
    
    print "Altitude      = " + myAltitude() at (5, 6).
    print "BurnHeight    = " + dist at (5, 7).
    print "SurfaceHeight = " + SurfaceHeight at (5, 8).

    print "VesselSpeed   = " + SHIP:VELOCITY:SURFACE:MAG at (5, 10).
    print "Engines       = " + i at (5, 11).
    
    print "M1 = " + SHIP:MASS at (5, 15).
    print "M2 = " + (M_2) at (5, 16).
}
