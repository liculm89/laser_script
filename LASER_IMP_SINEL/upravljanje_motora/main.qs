function onQueryStart()
{
  // TODO
}
function onLaserStop()
{
  // TODO
}
function onLaserStart()
{
  // TODO
}
function onLaserEnd()
{
  // TODO
}
function onLaserError(error)
{
  switch(error)
  {
    case System.DSP_IN_HANG:
      System.resetBoard();
      break;
    case System.DSP_ERROR_INIT:
      // This event is triggered each time the script engine starts
      // if the board was not properly loaded
      MessageBox.critical( "Board initialization error", MessageBox.Ok );
      break;
    // TODO
  }
}
function onClose()
{
  // TODO
}

const PIN_4 = 0x20;

function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
  // TODO
 //_Document = new LaserDoc;   
  //Document.enableAxis(2, true);
  //z_axis = new Axis;
  
  print( Axis.getOrigin(2));
  //print( Axis.isEnabled(1));
  print( Axis.isEnabled(2));
// print( Axis.isEnabled(3));
  print(IoPort.setPort(0, 0x20));
  print(IoPort.checkPort(PIN_4));
 /* 
dialog = new Dialog("Laser Dialog",Dialog.D_NONE,false);
dialog.newTab("Automatic");
dialog.newTab("Manual");
        dialog.setFixedSize(600,500);
        
        renderarea = new RenderArea();
        dialog.add(renderarea);
        
        theDoc = new LaserDoc;
        theDoc.load("test.xlp");
	var rect = new Rect( 10, 20, 30, 40 );

        renderarea.preview(theDoc);
	dialog.show();
  print( "Ready !" );
 */
   dialog = new Dialog("Demo font", Dialog.D_NONE, false);
  lbl = new Label();
  lbl.text = "The quick brown fox jumps over the lazy dog";
  dialog.add(lbl);
  lblFont = new Label();
 // lbl.font("Segoe Script");
  lblFont.text = lbl.font;
  dialog.add(lblFont);
  
  lbl2 = new Label();
  lbl2.loadImage("F:\\LASER_IMP_SINEL\\upravljanje_motora\\sinel.jpg");
  dialog.add(lbl2, w=2,h=2,aspectRatioMode = 2);
  print("Font: <font family>, <pointSizeF>, <pixelSize>, <QFont::StyleHint>, <QFont::Weight>, <QFont::Style>, <underline>, <strikeOut>, <fixedPitch>, <rawMode>");
  print("Font: " + lblFont.font);
  
  lbl.font = "MS Shell Dlg 2,18,-1,5,50,0,0,0,0,0";
  dialog.show();
  
}

