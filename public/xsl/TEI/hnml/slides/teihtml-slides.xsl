<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xd" 
    version="1.0"  >

<xsl:import href="../xhtml/tei.xsl"/>

<xsl:import href="slides-common.xsl"/>

<xsl:strip-space elements="teix:* rng:* xsl:*"/>

<xd:doc type="stylesheet">
    <xd:short>
      TEI stylesheet for making HTML presentations from TEI documents
      </xd:short>
    <xd:detail>
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   
      </xd:detail>
    <xd:author>Sebastian Rahtz sebastian.rahtz@oucs.ox.ac.uk</xd:author>
    <xd:cvsId>$Id: teihtml-slides.xsl,v 1.1 2006/02/16 15:31:45 giacomi Exp $</xd:cvsId>
    <xd:copyright>2005, TEI Consortium</xd:copyright>
  </xd:doc>
<xsl:output encoding="utf-8" 
	    method="xml"
	    doctype-public="-//W3C//DTD XHTML 1.1//EN"/>

<xsl:param name="outputEncoding">utf-8</xsl:param>
<xsl:param name="outputMethod" >xml</xsl:param>
<xsl:param name="outputSuffix" >.xhtml</xsl:param>
<xsl:param name="doctypePublic" >-//W3C//DTD XHTML 1.1//EN</xsl:param>
<xsl:param name="doctypeSystem">http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd</xsl:param>
<xsl:param name="startRed">&lt;span style="color:red"&gt;</xsl:param>
<xsl:param name="startBold">&lt;span class="element"&gt;</xsl:param>
<xsl:param name="endBold">&lt;/span&gt;</xsl:param>
<xsl:param name="startItalic">&lt;span class="attribute"&gt;</xsl:param>
<xsl:param name="endItalic">&lt;/span&gt;</xsl:param>
<xsl:param name="endRed">&lt;/span&gt;</xsl:param>
<xsl:param name="cssFile">http://www.tei-c.org/stylesheet/teislides.css</xsl:param>
<xsl:param name="logoFile">logo.png</xsl:param>
<xsl:param name="logoWidth">60</xsl:param>
<xsl:param name="logoHeight">60</xsl:param>
<xsl:param name="spaceCharacter">&#160;</xsl:param>
<xsl:template name="lineBreak">
  <xsl:param name="id"/>
<xsl:text>&#10;</xsl:text>
<!--
<xsl:text>(</xsl:text>
<xsl:value-of select="$id"/>
<xsl:text>)</xsl:text>
-->
</xsl:template>

<xsl:param name="numberHeadings"></xsl:param>
<xsl:param name="splitLevel">0</xsl:param>
<xsl:param name="subTocDepth">-1</xsl:param>
<xsl:param name="topNavigationPanel"></xsl:param>
<xsl:param name="bottomNavigationPanel">true</xsl:param>
<xsl:param name="linkPanel"></xsl:param>
<xsl:template name="copyrightStatement"/>
<xsl:param name="makingSlides">true</xsl:param>

<xsl:template match="div" mode="number">
  <xsl:number/>
</xsl:template>

<xsl:template match="div1" mode="number">
  <xsl:for-each select="parent::div0"><xsl:number/></xsl:for-each>_<xsl:number/>
</xsl:template>

<xsl:template match="div1|div" mode="genid">
  <xsl:value-of select="$masterFile"/>
  <xsl:apply-templates select="." mode="number"/>
</xsl:template>

<xsl:template match="docAuthor">
       <div class="docAuthor"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="docDate">
       <div class="docDate"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="/TEI.2">
<xsl:param name="slidenum">
  <xsl:value-of select="$masterFile"/>0</xsl:param>
  <xsl:call-template name="outputChunk">
   <xsl:with-param name="ident">
    <xsl:value-of select="$slidenum"/>
   </xsl:with-param>
   <xsl:with-param name="content">
    <xsl:call-template name="mainslide"/>
   </xsl:with-param>
  </xsl:call-template>
  <xsl:for-each select="text/body">
    <xsl:apply-templates select="div|div0"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="xrefpanel">
  <b><xsl:apply-templates select="." mode="number"/></b><xsl:text> </xsl:text>
  <xsl:variable name="first"><xsl:value-of
  select="$masterFile"/>0</xsl:variable>
  <xsl:variable name="prev">
    <xsl:choose>
      <xsl:when test="preceding-sibling::div">
	<xsl:apply-templates select="preceding-sibling::div[1]" mode="genid"/>
      </xsl:when>
      <xsl:when test="preceding::div1">
	<xsl:apply-templates select="preceding::div1[1]" mode="genid"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="not($prev='')">
    <a class="xreflink" accesskey="p" href="{concat($prev,'.xhtml')}"> 
      <span class="button">&#171;</span>
    </a>
  </xsl:if>
    
  <xsl:text>  </xsl:text>
  <a class="xreflink"  accesskey="f"
     href="{concat($first,'.xhtml')}"> 
    <span class="button">^</span>
  </a>
  
  <xsl:variable name="next">
    <xsl:choose>
      <xsl:when test="following-sibling::div">
	<xsl:apply-templates select="following-sibling::div[1]" mode="genid"/>
      </xsl:when>
      <xsl:when test="following::div1">
	<xsl:apply-templates select="following::div1[1]" mode="genid"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="not($next='')">
    <a class="xreflink" accesskey="n" href="{concat($next,'.xhtml')}"> 
      <span class="button">&#187;</span>
    </a>
  </xsl:if>
</xsl:template>

<xsl:template name="mainslide">
  <html>
    <xsl:call-template name="addLangAtt"/> 
  <head>
    <title> 
      <xsl:call-template name="generateTitle"/>
    </title>
    <xsl:call-template name="includeCSS"/>
    <xsl:call-template name="cssHook"/>
    <xsl:call-template name="javaScript"/>
  </head>
  <body>
    <div class="slidetitle" style="font-size: 36pt;">
      <xsl:call-template name="generateTitle"/>
    </div>
    <div class="slidemain">
      <xsl:apply-templates select="text/front//docAuthor"/>
      <xsl:apply-templates select="text/front//docDate"/>
      <ul class="slidetoc">
	<xsl:for-each select="text/body">
	  <xsl:for-each select="div|div0/div1">
	    <xsl:variable name="n"><xsl:apply-templates select="." mode="genid"/></xsl:variable>
	    <li class="slidetoc"> 
	      <a href="{$n}.xhtml"><xsl:value-of  select="head"/></a>
	    </li>
	  </xsl:for-each>
	  </xsl:for-each>
      </ul>
    </div>
    <div class="slidebottom">
      <img src="{$logoFile}" width="{$logoWidth}" height="${logoHeight}" alt="logo"/>
      <xsl:text> </xsl:text>
      <xsl:variable name="next"><xsl:value-of select="$masterFile"/>1</xsl:variable>
      <a accesskey="n" href="{concat($next,'.xhtml')}">Start</a>
    </div>
  </body>
  </html>
</xsl:template>

<xsl:template name="javaScriptHook">
  <xsl:variable name="prev">
    <xsl:choose>
      <xsl:when test="preceding-sibling::div">
	<xsl:apply-templates select="preceding-sibling::div[1]"
			     mode="genid"/>
      </xsl:when>
      <xsl:when test="preceding::div1">
	<xsl:apply-templates select="preceding::div1[1]" mode="genid"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$masterFile"/><xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="next">
    <xsl:choose>
      <xsl:when test="following-sibling::div">
	<xsl:apply-templates select="following-sibling::div[1]"
			     mode="genid"/>
      </xsl:when>
      <xsl:when test="following::div1">
	<xsl:apply-templates select="following::div1[1]" mode="genid"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$masterFile"/><xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
var isOp = navigator.userAgent.indexOf('Opera') > -1 ? 1 : 0;
function keys(key) {
	if (!key) {
		key = event;
		key.which = key.keyCode;
	}
 	switch (key.which) {
		case 10: // return
		case 32: // spacebar
		case 34: // page down
		case 39: // rightkey
		case 40: // downkey
			document.location = "<xsl:value-of select="$next"/>.xhtml";
			break;
		case 33: // page up
		case 37: // leftkey
		case 38: // upkey
			document.location = "<xsl:value-of select="$prev"/>.xhtml";
			break;
	}
}
function startup() {      
	if (!isOp) {		
		document.onkeyup = keys;
		document.onclick = clicker;
	}
}

function clicker(e) {
	var target;
	if (window.event) {
		target = window.event.srcElement;
		e = window.event;
	} else target = e.target;
 	if (target.href != null ) return true;
	if (!e.which || e.which == 1) 
	   document.location = "<xsl:value-of select="$next"/>.xhtml";
}

window.onload = startup;
</xsl:template>

<xsl:template match="body/div0">
      <xsl:variable name="slidenum"><xsl:value-of select="$masterFile"/>
      <xsl:number/></xsl:variable>
      <xsl:call-template name="outputChunk">
	<xsl:with-param name="ident">
	  <xsl:value-of select="$slidenum"/>
	</xsl:with-param>
	<xsl:with-param name="content">
	  <html>
	    <xsl:call-template name="addLangAtt"/> 
	    <head>
	      <title><xsl:value-of select="head"/></title>
	      <xsl:call-template name="includeCSS"/>
	      <xsl:call-template name="cssHook"/>
	      <xsl:call-template name="javaScript"/>
	    </head>
	    <body>
	      <h1><xsl:value-of select="head"/></h1>
	    </body>
	  </html>
	</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="div1"/>
</xsl:template>

<xsl:template match="body/div|div1">
  <xsl:choose>
    <xsl:when test="$splitLevel&gt;-1">
      <xsl:variable name="slidenum">
	<xsl:apply-templates select="." mode="genid"/>
      </xsl:variable>
      <xsl:call-template name="outputChunk">
	<xsl:with-param name="ident">
	  <xsl:value-of select="$slidenum"/>
	</xsl:with-param>
	<xsl:with-param name="content">
	  <xsl:call-template name="slideout"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="slidebody"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="slideout">
  <html>
    <xsl:call-template name="addLangAtt"/> 
    <head>
      <title><xsl:value-of select="head"/></title>
      <xsl:call-template name="includeCSS"/>
      <xsl:call-template name="cssHook"/>
      <xsl:call-template name="javaScript"/>
    </head>
    <body>
      <xsl:call-template name="slidebody"/>
    </body>
  </html>
</xsl:template>


<xsl:template name="slidebody">
  <div  class="slidetop">
    <div class="slidetitle"><xsl:call-template name="header"/></div>
    <xsl:if test="$splitLevel &gt;-1">
      <div class="xref"><xsl:call-template name="xrefpanel"/>
      </div>
    </xsl:if>
  </div>
  <div class="slidemain">
    <xsl:apply-templates/>
  </div>
  <div class="slidebottom">
    <xsl:call-template name="slideBottom"/>
  </div>
</xsl:template>

<xsl:template name="slideBottom">
  <img src="{$logoFile}" width="{$logoWidth}" height="{$logoHeight}" alt="logo"/>
  <xsl:text> </xsl:text>
  <xsl:call-template name="generateTitle"/>
</xsl:template>


<xsl:template name="writeJavascript">
  <xsl:param name="content"/>
  <script type="text/javascript">
    <xsl:value-of select="$content"/>
  </script>
</xsl:template>

<xsl:template match="teix:egXML">
  <pre>
    <xsl:apply-templates mode="verbatim"/>
  </pre>
</xsl:template>

</xsl:stylesheet>