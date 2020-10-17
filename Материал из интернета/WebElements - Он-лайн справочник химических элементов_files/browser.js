function BrowserInfo() {
  var agt = navigator.userAgent.toLowerCase();
  this.version = parseFloat(navigator.appVersion);
  this.isIE = (agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1);
  this.isIE4up = this.isIE && (this.version >= 4);
  if (this.isIE) {
    if (this.isIE4up) {
      if (agt.indexOf("msie 6") != -1) this.version = 6;
      else if (agt.indexOf("msie 5.5") != -1) this.version = 5.5;
      else if (agt.indexOf("msie 5") != -1) this.version = 5;
    } else
      this.version = 3;
  }
  this.isIE5up = this.isIE && (this.version >= 5);
  this.isIE5_5up = this.isIE && (this.version >= 5.5);
  this.isIE6up = this.isIE && (this.version >= 6);
  this.isNN = (agt.indexOf('mozilla') != -1) && (agt.indexOf('spoofer') == -1) &&
              (agt.indexOf('compatible') == -1) && (agt.indexOf('opera') == -1) &&
              (agt.indexOf('webtv') == -1) && (agt.indexOf('hotjava') == -1);
  this.isNN4up = this.isNN && (this.version >= 4);
  this.isNN6up = this.isNN && (this.version >= 5);
  this.isOnline = true;
  if (this.isIE4up)
    this.isOnline = navigator.onLine;
  this.name = "Unknown";
  if (this.isIE)
    this.name = "Internet Explorer";
  else if (agt.indexOf("netscape6/") != -1) {
    this.name = "Netscape";
    this.version = parseFloat(agt.substr(agt.indexOf("netscape6/") + 10));
    if (!this.version) this.version = 6;
  } else if (agt.indexOf('gecko') != -1)
    this.name = "Mozilla";
  else if (this.isNN)
    this.name = "Netscape Navigator";
  else if (agt.indexOf("aol") != -1) {
    this.name = "AOL Browser";
    if (this.version < 4) this.version = 3;
  }
  else if (agt.indexOf("opera") != -1) {
    this.name = "Opera";
    this.version = parseFloat(agt.substr(agt.indexOf("opera") + 6));
  }
  else if (agt.indexOf("webtv") != -1)
    this.name = "WebTV";
  else if ((agt.indexOf("navio") != -1) || (agt.indexOf("navio_aoltv") != -1))
    this.name = "AOL TV Navigator";
  else if (agt.indexOf("hotjava") != -1)
    this.name = "HotJava";
  this.fullName = this.name + ' ' + this.version;
  if (this.version == Math.floor(this.version))
    this.fullName += '.0';
  //Добавление для сайта webelements:
  //if (this.isIE5up || this.isNN6up)
  //  this.supportIFrame == true;
  this.supportIFrame = (this.isIE5up || (this.isNN && (this.version == 7))) && !(this.isIE6up);
  //if (this.isIE6up) this.supportIFrame = false;
}

// Объект, содержащий информацию о текущем браузере.
var currentBrowser = new BrowserInfo();

