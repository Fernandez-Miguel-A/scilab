// =============================================================================
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2008 - INRIA - Pierre MARECHAL <pierre.marechal@inria.fr>
//
//  This file is distributed under the same license as the Scilab package.
// =============================================================================

// <-- CLI SHELL MODE -->

// <-- Non-regression test for bug 2721 -->
//
// <-- Bugzilla URL -->
// http://bugzilla.scilab.org/show_bug.cgi?id=2721
//

// <-- Short Description -->
//   strcat function return weird strings.

if or(strcat(string([1 2; 3 4])," ","r") <> ["1 3" "2 4"]) then pause, end
if or(strcat(string([1 2; 3 4])," ","c") <> ["1 2";"3 4"]) then pause, end
