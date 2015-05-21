/*!
 * Snarl - Web Notifications based on Growl
 * @version v0.3.2
 * @link https://hoxxep.github.io/snarl
 *
 * Copyright 2014-2015 Liam Gray <hoxxep@gmail.com>
 * Released under the MIT license
 * @license https://github.com/hoxxep/Snarl/blob/master/LICENSE 
 */
!function(t,i){"use strict";function n(){var t="",i="abcdefghijklmnopqrstuvwxyz0123456789";do{t="";for(var n=0;5>n;n++)t+=i.charAt(Math.floor(Math.random()*i.length))}while(u.exists(t));return t}function e(i){if("snarl-wrapper"!==i.toElement.getAttribute("id")){for(var n=i.toElement,e=!1;!l(n,"snarl-notification");)l(n,"snarl-close")&&(e=!0),n=n.parentElement;var o=n.getAttribute("id");if(o=/snarl-notification-([a-zA-Z0-9]+)/.exec(o)[1],e&&u.notifications[o].options.dismissable)u.removeNotification(o);else{var a=u.notifications[o].action;if(void 0===a||null===a)return;"string"==typeof a?t.location=a:"function"==typeof a?a(o):(console.log("Snarl Error: Invalid click action:"),console.log(a))}}}function o(t){if(void 0===u.notifications[t]&&(u.notifications[t]={}),null===u.notifications[t].element||void 0===u.notifications[t].element){var n=d.cloneNode(!0);s(n,"snarl-notification"),n.setAttribute("id","snarl-notification-"+t),u.notifications[t].element=n}if(null===u.notifications[t].element.parentElement){var e=i.getElementById("snarl-wrapper");i.body.clientWidth>480?e.appendChild(u.notifications[t].element):e.insertBefore(u.notifications[t].element,e.firstChild)}}function a(t,i){var n,e={};for(n in t)e[n]=t[n];for(n in i)e[n]=i[n];return e}function s(t,i){l(t,i)||(t.className+=" "+i)}function l(t,i){var n=new RegExp("(?:^|\\s)"+i+"(?!\\S)","g");return null!==t.className.match(n)}function c(t,i){var n=new RegExp("(?:^|\\s)"+i+"(?!\\S)","g");t.className=t.className.replace(n,"")}function r(){return"ontouchstart"in t||"onmsgesturechange"in t}function f(){var t=i.createElement("div");t.setAttribute("id","snarl-wrapper"),t.addEventListener("click",e),i.body.appendChild(t),u.setNotificationHTML('<div class="snarl-notification waves-effect"><div class="snarl-icon"></div><h3 class="snarl-title"></h3><p class="snarl-text"></p><div class="snarl-close waves-effect"><svg class="snarl-close-svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Layer_1" x="0px" y="0px" viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve" height="100px" width="100px"><g><path d="M49.5,5c-24.9,0-45,20.1-45,45s20.1,45,45,45s45-20.1,45-45S74.4,5,49.5,5z M71.3,65.2c0.3,0.3,0.5,0.7,0.5,1.1   s-0.2,0.8-0.5,1.1L67,71.8c-0.3,0.3-0.7,0.5-1.1,0.5s-0.8-0.2-1.1-0.5L49.5,56.6L34.4,71.8c-0.3,0.3-0.7,0.5-1.1,0.5   c-0.4,0-0.8-0.2-1.1-0.5l-4.3-4.4c-0.3-0.3-0.5-0.7-0.5-1.1c0-0.4,0.2-0.8,0.5-1.1L43,49.9L27.8,34.9c-0.6-0.6-0.6-1.6,0-2.3   l4.3-4.4c0.3-0.3,0.7-0.5,1.1-0.5c0.4,0,0.8,0.2,1.1,0.5l15.2,15l15.2-15c0.3-0.3,0.7-0.5,1.1-0.5s0.8,0.2,1.1,0.5l4.3,4.4   c0.6,0.6,0.6,1.6,0,2.3L56.1,49.9L71.3,65.2z"/></g></svg></div></div>')}var u=u||{};u={count:0,notifications:{},defaultOptions:{title:"",text:"",icon:"",timeout:5e3,action:null,dismissable:!0},setDefaultOptions:function(t){u.defaultOptions=a(u.defaultOptions,t)},setNotificationHTML:function(t){var n=i.createElement("div");n.innerHTML=t;var e=n.firstChild;n.removeChild(e),d=e},addNotification:function(t){u.count+=1;var i=n();return o(i),u.editNotification(i,t),i},editNotification:function(t,i){null!==u.notifications[t].removeTimer&&(clearTimeout(u.notifications[t].removeTimer),u.notifications[t].removeTimer=null),o(t),i=i||{},void 0===u.notifications[t].options&&(u.notifications[t].options=u.defaultOptions),i=a(u.notifications[t].options,i);var n=u.notifications[t].element,e=n.getElementsByClassName("snarl-title")[0];i.title?(e.textContent=i.title,c(n,"snarl-no-title")):(e.textContent="",s(n,"snarl-no-title"));var l=n.getElementsByClassName("snarl-text")[0];i.text?(l.textContent=i.text,c(n,"snarl-no-text")):(l.textContent="",s(n,"snarl-no-text"));var f=n.getElementsByClassName("snarl-icon")[0];i.icon?(f.innerHTML=i.icon,c(n,"snarl-no-icon")):(f.innerHTML="",s(n,"snarl-no-icon")),null!==i.timer&&clearTimeout(u.notifications[t].timer);var d=null;null!==i.timeout&&(d=setTimeout(function(){u.removeNotification(t)},i.timeout)),u.notifications[t].timer=d,u.notifications[t].action=i.action,i.dismissable?c(n,"not-dismissable"):s(n,"not-dismissable"),setTimeout(function(){s(n,"snarl-in"),n.removeAttribute("style")},0),r()&&s(n,"no-hover"),u.notifications[t].options=i},reOpenNotification:function(t){u.editNotification(t)},removeNotification:function(t){if(u.isDismissed(t))return!1;var n=u.notifications[t].element;return c(n,"snarl-in"),i.body.clientWidth>480?n.style.marginBottom=-n.offsetHeight+"px":n.style.marginTop=-n.offsetHeight+"px",u.notifications[t].removeTimer=setTimeout(function(){n.parentElement.removeChild(n)},500),clearTimeout(u.notifications[t].timer),!0},isDismissed:function(t){return u.exists(t)?null===u.notifications[t].element.parentElement:!0},exists:function(t){return void 0!==u.notifications[t]},setTitle:function(t,i){u.editNotification(t,{title:i})},setText:function(t,i){u.editNotification(t,{text:i})},setIcon:function(t,i){u.editNotification(t,{icon:i})},setTimeout:function(t,i){u.editNotification(t,{timeout:i})}};var d=null;!function(){"complete"===i.readyState||"interactive"===i.readyState&&i.body?f():i.addEventListener?i.addEventListener("DOMContentLoaded",function(){i.removeEventListener("DOMContentLoaded",null,!1),f()},!1):i.attachEvent&&i.attachEvent("onreadystatechange",function(){"complete"===i.readyState&&(i.detachEvent("onreadystatechange",null),f())})}(),t.Snarl=u}(window,document);