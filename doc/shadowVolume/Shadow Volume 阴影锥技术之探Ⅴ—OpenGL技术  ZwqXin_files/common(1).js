function HPFGSwitchMenu(obj,sty)
{
	if(document.getElementById)
	{
	var el = document.getElementById(obj);
	var ml = document.getElementById(sty);
	var ar = document.getElementById("hpfg-side").getElementsByTagName("p");
	var mr = document.getElementById("hpfg-side").getElementsByTagName("div");
		if(el.style.display != "block")
		{
			for (var i=0; i<ar.length; i++)
			{
				if (ar[i].className == "hpfg-item")
				ar[i].style.display = "none";
			}
			for (var i=0; i<mr.length; i++)
			{
				if (mr[i].className == "hpfg-title-a")
				mr[i].className = "hpfg-title";
			}
			el.style.display = "block";
			ml.className ="hpfg-title-a";
		}
		else
		{
			el.style.display = "none";
			ml.className ="hpfg-title";
		}
	}
}