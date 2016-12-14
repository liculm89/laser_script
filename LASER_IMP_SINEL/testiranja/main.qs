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
function main()
{
  System.sigQueryStart.connect(onQueryStart);
  System.sigLaserStop.connect(onLaserStop);
  System.sigLaserStart.connect(onLaserStart);
  System.sigLaserEnd.connect(onLaserEnd);
  System["sigLaserError(int)"].connect(onLaserError);
  System.sigClose.connect(onClose);
  // TODO
  var part_list_file = new File("F:\\LASER_IMP_SINEL\\parts_list.txt");
  
  part_list_file.open(File.ReadOnly);
 // var part_list = part_list_file.readLine();	 
  
  
  
  var part_list = []
  var i = 0;		  
  
 while (!part_list_file.eof )
  {
    part_list[i] = part_list_file.readLine();
  // print (part_list[i]);
    i = i + 1;
}
  
  //print(part_list);     

 dialog = new Dialog("Demo font", Dialog.D_NONE, false);
 
 box = new ComboBox("Select type:", part_list);

 dialog.add(box);
  lbl = new Label();
  lbl.text = "The quick brown fox jumps over the lazy dog";
  dialog.add(lbl);
  lblFont = new Label();
  lblFont.text = lbl.font;
  dialog.add(lblFont);
 
  dialog.show();

		       

  print( "Ready !" );
}

