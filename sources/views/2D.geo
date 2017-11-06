#ifndef ADAPT
adapt = 0;
#else
adapt = 1;
#endif

If(!Exists(field))
  field = "phi";
EndIf

If(!Exists(video))
  video = 0;
EndIf

If(!Exists(step))
  step = 1;
EndIf

If(!Exists(startAt))
  startAt = 0;
EndIf

If(!Exists(maxIters))
  maxIters = 10000;
EndIf

If(video == 1)
  System StrCat("mkdir -p pictures/", field);
EndIf

If (adapt == 0)
  Merge "output/mesh.msh";
EndIf

For i In {0:maxIters}
  iteration = startAt + i*step;
  If (FileExists(Sprintf("output/done/done-%g.txt", iteration)))
    If (adapt == 1)
      Merge StrCat("output/", field, "/", field, Sprintf("-%g.pos", iteration));
      View[i].Visible = 1;
    EndIf
    If (adapt == 0)
      Merge StrCat("output/", field, "/", field, Sprintf("-%g.msh", iteration));
    EndIf
    Draw;
    If(video == 1)
      Print StrCat("pictures/", field, "/", field, Sprintf("-%04g.png", iteration));
    EndIf
    If (adapt == 1)
      View[i].Visible = 0;
    EndIf
  EndIf
  If (!FileExists(Sprintf("output/done/done-%g.txt", iteration)))
    Sleep .1; Draw; i = i - 1;
  EndIf
EndFor
