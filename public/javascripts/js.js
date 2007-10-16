// JavaScript Document

// BROWSER DETECT
var BrowserDetect = {
        init: function () {
                this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
                this.version = this.searchVersion(navigator.userAgent)
                        || this.searchVersion(navigator.appVersion)
                        || "an unknown version";
                this.OS = this.searchString(this.dataOS) || "an unknown OS";
        },
        searchString: function (data) {
                for (var i=0;i<data.length;i++) {
                        var dataString = data[i].string;
                        var dataProp = data[i].prop;
                        this.versionSearchString = data[i].versionSearch || data[i].identity;
                        if (dataString) {
                                if (dataString.indexOf(data[i].subString) != -1)
                                        return data[i].identity;
                        }
                        else if (dataProp)
                                return data[i].identity;
                }
        },
        searchVersion: function (dataString) {
                var index = dataString.indexOf(this.versionSearchString);
                if (index == -1) return;
                return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
        },
        dataBrowser: [
                {
                        string: navigator.vendor,
                        subString: "Apple",
                        identity: "Safari"
                },
                {
                        prop: window.opera,
                        identity: "Opera"
                },
                {
                        string: navigator.vendor,
                        subString: "iCab",
                        identity: "iCab"
                },
                {
                        string: navigator.vendor,
                        subString: "KDE",
                        identity: "Konqueror"
                },
                {
                        string: navigator.userAgent,
                        subString: "Firefox",
                        identity: "Firefox"
                },
                {       // for newer Netscapes (6+)
                        string: navigator.userAgent,
                        subString: "Netscape",
                        identity: "Netscape"
                },
                {
                        string: navigator.userAgent,
                        subString: "MSIE",
                        identity: "Explorer",
                        versionSearch: "MSIE"
                },
                {
                        string: navigator.userAgent,
                        subString: "Gecko",
                        identity: "Mozilla",
                        versionSearch: "rv"
                },
                {       // for older Netscapes (4-)
                        string: navigator.userAgent,
                        subString: "Mozilla",
                        identity: "Netscape",
                        versionSearch: "Mozilla"
                }
        ],
        dataOS : [
                {
                        string: navigator.platform,
                        subString: "Win",
                        identity: "Windows"
                },
                {
                        string: navigator.platform,
                        subString: "Mac",
                        identity: "Mac"
                },
                {
                        string: navigator.platform,
                        subString: "Linux",
                        identity: "Linux"
                }
        ]

};
BrowserDetect.init();

var ofsTop=290;

function setDivHeight()
{ 
	/* reset dei valori degli elemnenti */
	$('ext_page').style.height = "100%";
	$('side_bar').style.height = "auto";
	
	var windowHeight = 0; // WINDOW HEIGHT
	var windowWidth = 0; // WINDOW WIDTH
	
	var ext_pageHeight = $('ext_page').clientHeight; // DIV ext_page HEIGHT
	var ext_pageWidth = $('ext_page').clientWidth;; // DIV ext_page WIDTH
  
 // lettura dell'altezza e larghezza della finestra
 if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    windowHeight = window.innerHeight;
	windowWidth = window.innerWidth;
  } else if( document.documentElement &&
      ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    windowHeight = document.documentElement.clientHeight;
	windowWidth = document.documentElement.clientWidth;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    windowHeight = document.body.clientHeight;
	windowWidth = document.body.clientWidth;
  }

	/*alert("WINDOW WIDTH: " + windowWidth + ", WINDOW HEIGHT: " + windowHeight +
		  " ,ext_pageHeight: " + ext_pageHeight + " ,ext_pageWidth: " + ext_pageWidth); */
	
	/* gestiona altezza div ext_page:
	se l'altezza del div è inferiore all'altezza della
	pagina forzo l'altezza uguale a quella della pagina */
	
	/* !!!!!! CONTROLLARE IL CORRETTO FUNZIONAMENTO SU ALTRE PIATTAFORME !!!!!!!!!!!! */
if((windowHeight-290-158-window.pageYOffset)>0)
	 $("bottom_menu").style.marginTop =290+(windowHeight-290-158-window.pageYOffset) + ("px");
         else  $("bottom_menu").style.marginTop =290+ ("px");
	
if(ext_pageHeight < windowHeight)
	{


		$('ext_page').style.height = (windowHeight) + ("px");
               
	

     } else {  $("bottom_menu").style.marginTop = windowHeight - 218  + ("px"); }
	
	
	/* dimensionamento del side bar: se non arriva fino in fodno alla pagina, lo imposto con lo style perché arrivi in fondo */
	if(($('side_bar').clientHeight + 158) < windowHeight)
	{
                 
		      $('side_bar').style.height =  (windowHeight - 158) + "px";
         
	} 
// (window.pageYOffset/2);


}

/* funzione per aprire e chiudere la side_bar  element_id -> id dell'elemento da chiudere, classOpen -> il nome della classe css per l'elemento aperto,  classClosed-> il nome della classe css per l'elemento chiuso */

function open_close(elementId , classOpen, classClosed){

if($(elementId).hasClassName(classOpen)){
	
	$(elementId).removeClassName(classOpen); 
	$(elementId).addClassName(classClosed);
}
else{
	$(elementId).removeClassName(classClosed); 
	$(elementId).addClassName(classOpen);
}


}


function updateSideBarContent(url){

alert(url); return false;

}

function applyClickToSidebarButton(buttonClass){

pippo = $$(buttonClass);

for(i=0;i<pippo.length;i++){

	pippo[i].onclick=function(){ 

		 updateSideBarContent(this.href); return false;
                   
	}


}


}


function pixel2int( pixels){

//return parseInt(pixels.substring(0,pixels.length-2));


}

/* funzione che fa scorrere un oggetto in base allo scroll e altra misura. */

function scroll_element(elementId, morePixel){

if( typeof( window.pageYOffset ) == 'number' ) {

    //Netscape compliant
$(elementId).style.marginTop =morePixel +  window.pageYOffset +"px";
  
  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
    //DOM compliant
   $(elementId).style.marginTop =morePixel +  document.body.scrollTop/2 +"px";

  } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
    //IE6 standards compliant mode
 
  $(elementId).style.marginTop =morePixel +   document.documentElement.scrollTop/2 +"px";

  
 }


}

var margin_bottom_menu = 290;

var size= window.innerHeight;
var newsize = window.innerHeight;


window.onresize = function(){

 
  setDivHeight();

}


window.onload = function(){


applyClickToSidebarButton("a.top_menu_item");



$("bottom_menu").style.marginTop = 290 +"px";
$("top_menu").style.marginTop = 60 +"px";

/* calcolo la distanza che bottom_menu ha dalla testata*/

//margin_bottom_menu = pixel2int($("top_menu").style.marginTop) + pixel2int($("top_menu").clientHeight);
  

  

 setDivHeight();

 /* applico al pulsante con id 'sidebar_button' le funzioni per aprire e chiudere side_bar */

	$('side_bar_button').onclick=function(){
	open_close("side_bar" , "open", "closed");
	open_close("contents_ext", "open", "closed");
        open_close("footer", "open", "closed");
        open_close("page", "open", "closed");

  }


}

window.onscroll = function() {


}

