//  Scicos
//
//  Copyright (C) INRIA - METALAU Project <scicos@inria.fr>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// See the file ../license.txt
//

function [x,y,typ]=INTEGRAL(job,arg1,arg2)
    x=[];y=[];typ=[];
    select job
    case "plot" then
        standard_draw(arg1)
    case "getinputs" then
        [x,y,typ]=standard_inputs(arg1)
    case "getoutputs" then
        [x,y,typ]=standard_outputs(arg1)
    case "getorigin" then
        [x,y]=standard_origin(arg1)
    case "set" then
        x=arg1;
        graphics=arg1.graphics;exprs=graphics.exprs
        model=arg1.model;
        while %t do
            [ok,x0,reinit,satur,maxp,lowp,exprs]=scicos_getvalue("Set Integral block parameters",..
            ["Initial Condition";
            "With re-intialization (1:yes, 0:no)";"With saturation (1:yes, 0:no)";
            "Upper limit";"Lower limit"],..
            list("vec",-1,"vec",1,"vec",1,"vec",-1,"vec",-1),exprs)
            if ~ok then break,end
            x0=x0(:);maxp=maxp(:),lowp=lowp(:)
            if reinit<>0 then reinit=1;end
            if satur<>0 then
                satur=1;
                if size(maxp,"*")==1 then maxp=maxp*ones(x0),end
                if size(lowp,"*")==1 then lowp=lowp*ones(x0),end
                if (size(x0,1)<>size(maxp,1) | size(x0,1)<>size(lowp,1)) then
                    message("x0 and Upper limit and Lower limit must have same size")
                    ok=%f
                elseif or(maxp<=lowp)  then
                    message("Upper limits must be > Lower limits")
                    ok=%f
                elseif or(x0>maxp)|or(x0<lowp) then
                    message("Inital condition x0 should be inside the limits")
                    ok=%f
                else
                    rpar=[maxp;lowp]
                    model.nzcross=size(x0,1)
                    model.nmode=size(x0,1)
                end
            else
                rpar=[]
                model.nzcross=0
                model.nmode=0
            end
            if ok then
                model.rpar=rpar
                model.state=x0
                [model,graphics,ok]=check_io(model,graphics,..
                size(x0,1)*[1;ones(reinit,1)],size(x0,1),ones(reinit,1),[])
            end
            if ok then
                graphics.exprs=exprs
                x.graphics=graphics;x.model=model
                break
            end
        end
    case "define" then
        maxp=1;minp=-1;rpar=[]
        model=scicos_model()
        model.state=0
        model.sim=list("integral_func",4)
        model.in=1
        model.out=1
        model.rpar=rpar
        model.blocktype="c"
        model.dep_ut=[%f %t]

        exprs=string([0;0;0;maxp;minp])
        gr_i=["thick=xget(''thickness'')"
        "pat=xget(''pattern'')"
        "fnt=xget(''font'')"
        "xpoly(orig(1)+[0.7;0.62;0.549;0.44;0.364;0.291]*sz(1),orig(2)+[0.947;0.947;0.884;0.321;0.255;0.255]*sz(2),"'lines"')"
        "xset(''thickness'',thick)"
        "xset(''pattern'',pat)"
        "xset(''font'',fnt(1),fnt(2))"
        ]
        x=standard_define([2 2],model,exprs,gr_i)
        x.graphics.id="1/s"
    end
endfunction