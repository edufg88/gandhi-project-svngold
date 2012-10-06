class GPMenuGfx extends GFxMoviePlayer;

function Init(optional LocalPlayer LocalPlayer)
{
	super.Init(LocalPlayer);

	Start();
	Advance(0);
}

function hideMenu() 
{
	Close();
}

function exitGame() 
{
	ConsoleCommand("Quit");
}

DefaultProperties
{
	bDisplayWithHudOff=true
	TimingMode=TM_Real
	MovieInfo=SwfMovie'GandhiMenu.GandhiMenu'
	bPauseGameWhileActive=true
}
