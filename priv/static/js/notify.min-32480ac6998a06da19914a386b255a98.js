/** Notify.js - v0.3.2 - 2015/06/03
 * http://notifyjs.com/
 * Copyright (c) 2015 Jaime Pillora - MIT
 */
(function(t,i,n,e){"use strict";var r,o,s,a,h,l,c,u,p,d,f,m,w,y,g,b,v,x,S,P,C,N,k,H,T,A,M,j=[].indexOf||function(t){for(var i=0,n=this.length;n>i;i++)if(i in this&&this[i]===t)return i;return-1};C="notify",P=C+"js",s=C+"!blank",k={t:"top",m:"middle",b:"bottom",l:"left",c:"center",r:"right"},w=["l","c","r"],M=["t","m","b"],v=["t","b","l","r"],x={t:"b",m:null,b:"t",l:"r",c:null,r:"l"},S=function(t){var i;return i=[],n.each(t.split(/\W+/),function(t,n){var r;return r=n.toLowerCase().charAt(0),k[r]?i.push(r):e}),i},A={},a={name:"core",html:'<div class="'+P+'-wrapper">\n  <div class="'+P+'-arrow"></div>\n  <div class="'+P+'-container"></div>\n</div>',css:"."+P+"-corner {\n  position: fixed;\n  margin: 5px;\n  z-index: 1050;\n}\n\n."+P+"-corner ."+P+"-wrapper,\n."+P+"-corner ."+P+"-container {\n  position: relative;\n  display: block;\n  height: inherit;\n  width: inherit;\n  margin: 3px;\n}\n\n."+P+"-wrapper {\n  z-index: 1;\n  position: absolute;\n  display: inline-block;\n  height: 0;\n  width: 0;\n}\n\n."+P+"-container {\n  display: none;\n  z-index: 1;\n  position: absolute;\n}\n\n."+P+"-hidable {\n  cursor: pointer;\n}\n\n[data-notify-text],[data-notify-html] {\n  position: relative;\n}\n\n."+P+"-arrow {\n  position: absolute;\n  z-index: 2;\n  width: 0;\n  height: 0;\n}"},T={"border-radius":["-webkit-","-moz-"]},f=function(t){return A[t]},o=function(i,e){var r,o,s,a;if(!i)throw"Missing Style name";if(!e)throw"Missing Style definition";if(!e.html)throw"Missing Style HTML";return(null!=(a=A[i])?a.cssElem:void 0)&&(t.console&&console.warn(""+C+": overwriting style '"+i+"'"),A[i].cssElem.remove()),e.name=i,A[i]=e,r="",e.classes&&n.each(e.classes,function(t,i){return r+="."+P+"-"+e.name+"-"+t+" {\n",n.each(i,function(t,i){return T[t]&&n.each(T[t],function(n,e){return r+="  "+e+t+": "+i+";\n"}),r+="  "+t+": "+i+";\n"}),r+="}\n"}),e.css&&(r+="/* styles for "+e.name+" */\n"+e.css),r&&(e.cssElem=b(r),e.cssElem.attr("id","notify-"+e.name)),s={},o=n(e.html),p("html",o,s),p("text",o,s),e.fields=s},b=function(t){var i;i=h("style"),i.attr("type","text/css"),n("head").append(i);try{i.html(t)}catch(e){i[0].styleSheet.cssText=t}return i},p=function(t,i,e){var r;return"html"!==t&&(t="text"),r="data-notify-"+t,u(i,"["+r+"]").each(function(){var i;return i=n(this).attr(r),i||(i=s),e[i]=t})},u=function(t,i){return t.is(i)?t:t.find(i)},N={clickToHide:!0,autoHide:!0,autoHideDelay:5e3,arrowShow:!0,arrowSize:5,breakNewLines:!0,elementPosition:"bottom",globalPosition:"top right",style:"bootstrap",className:"error",showAnimation:"slideDown",showDuration:400,hideAnimation:"slideUp",hideDuration:200,gap:5},g=function(t,i){var e;return e=function(){},e.prototype=t,n.extend(!0,new e,i)},l=function(t){return n.extend(N,t)},h=function(t){return n("<"+t+"></"+t+">")},m={},d=function(t){var i;return t.is("[type=radio]")&&(i=t.parents("form:first").find("[type=radio]").filter(function(i,e){return n(e).attr("name")===t.attr("name")}),t=i.first()),t},y=function(t,i,n){var r,o;if("string"==typeof n)n=parseInt(n,10);else if("number"!=typeof n)return;if(!isNaN(n))return r=k[x[i.charAt(0)]],o=i,t[r]!==e&&(i=k[r.charAt(0)],n=-n),t[i]===e?t[i]=n:t[i]+=n,null},H=function(t,i,n){if("l"===t||"t"===t)return 0;if("c"===t||"m"===t)return n/2-i/2;if("r"===t||"b"===t)return n-i;throw"Invalid alignment"},c=function(t){return c.e=c.e||h("div"),c.e.text(t).html()},r=function(){function t(t,i,e){"string"==typeof e&&(e={className:e}),this.options=g(N,n.isPlainObject(e)?e:{}),this.loadHTML(),this.wrapper=n(a.html),this.options.clickToHide&&this.wrapper.addClass(""+P+"-hidable"),this.wrapper.data(P,this),this.arrow=this.wrapper.find("."+P+"-arrow"),this.container=this.wrapper.find("."+P+"-container"),this.container.append(this.userContainer),t&&t.length&&(this.elementType=t.attr("type"),this.originalElement=t,this.elem=d(t),this.elem.data(P,this),this.elem.before(this.wrapper)),this.container.hide(),this.run(i)}return t.prototype.loadHTML=function(){var t;return t=this.getStyle(),this.userContainer=n(t.html),this.userFields=t.fields},t.prototype.show=function(t,i){var n,r,o,s,a,h=this;if(r=function(){return t||h.elem||h.destroy(),i?i():e},a=this.container.parent().parents(":hidden").length>0,o=this.container.add(this.arrow),n=[],a&&t)s="show";else if(a&&!t)s="hide";else if(!a&&t)s=this.options.showAnimation,n.push(this.options.showDuration);else{if(a||t)return r();s=this.options.hideAnimation,n.push(this.options.hideDuration)}return n.push(r),o[s].apply(o,n)},t.prototype.setGlobalPosition=function(){var t,i,e,r,o,s,a,l;return l=this.getPosition(),a=l[0],s=l[1],o=k[a],t=k[s],r=a+"|"+s,i=m[r],i||(i=m[r]=h("div"),e={},e[o]=0,"middle"===t?e.top="45%":"center"===t?e.left="45%":e[t]=0,i.css(e).addClass(""+P+"-corner"),n("body").append(i)),i.prepend(this.wrapper)},t.prototype.setElementPosition=function(){var t,i,r,o,s,a,h,l,c,u,p,d,f,m,g,b,S,P,C,N,T,A,z,D,E,L,O,I,W;for(z=this.getPosition(),N=z[0],P=z[1],C=z[2],p=this.elem.position(),l=this.elem.outerHeight(),d=this.elem.outerWidth(),c=this.elem.innerHeight(),u=this.elem.innerWidth(),D=this.wrapper.position(),s=this.container.height(),a=this.container.width(),m=k[N],b=x[N],S=k[b],h={},h[S]="b"===N?l:"r"===N?d:0,y(h,"top",p.top-D.top),y(h,"left",p.left-D.left),W=["top","left"],E=0,O=W.length;O>E;E++)T=W[E],g=parseInt(this.elem.css("margin-"+T),10),g&&y(h,T,g);if(f=Math.max(0,this.options.gap-(this.options.arrowShow?r:0)),y(h,S,f),this.options.arrowShow){for(r=this.options.arrowSize,i=n.extend({},h),t=this.userContainer.css("border-color")||this.userContainer.css("background-color")||"white",L=0,I=v.length;I>L;L++)T=v[L],A=k[T],T!==b&&(o=A===m?t:"transparent",i["border-"+A]=""+r+"px solid "+o);y(h,k[b],r),j.call(v,P)>=0&&y(i,k[P],2*r)}else this.arrow.hide();return j.call(M,N)>=0?(y(h,"left",H(P,a,d)),i&&y(i,"left",H(P,r,u))):j.call(w,N)>=0&&(y(h,"top",H(P,s,l)),i&&y(i,"top",H(P,r,c))),this.container.is(":visible")&&(h.display="block"),this.container.removeAttr("style").css(h),i?this.arrow.removeAttr("style").css(i):e},t.prototype.getPosition=function(){var t,i,n,e,r,o,s,a;if(i=this.options.position||(this.elem?this.options.elementPosition:this.options.globalPosition),t=S(i),0===t.length&&(t[0]="b"),n=t[0],0>j.call(v,n))throw"Must be one of ["+v+"]";return(1===t.length||(e=t[0],j.call(M,e)>=0&&(r=t[1],0>j.call(w,r)))||(o=t[0],j.call(w,o)>=0&&(s=t[1],0>j.call(M,s))))&&(t[1]=(a=t[0],j.call(w,a)>=0?"m":"l")),2===t.length&&(t[2]=t[1]),t},t.prototype.getStyle=function(t){var i;if(t||(t=this.options.style),t||(t="default"),i=A[t],!i)throw"Missing style: "+t;return i},t.prototype.updateClasses=function(){var t,i;return t=["base"],n.isArray(this.options.className)?t=t.concat(this.options.className):this.options.className&&t.push(this.options.className),i=this.getStyle(),t=n.map(t,function(t){return""+P+"-"+i.name+"-"+t}).join(" "),this.userContainer.attr("class",t)},t.prototype.run=function(t,i){var r,o,a,h,l,p=this;if(n.isPlainObject(i)?n.extend(this.options,i):"string"===n.type(i)&&(this.options.className=i),this.container&&!t)return this.show(!1),e;if(this.container||t){o={},n.isPlainObject(t)?o=t:o[s]=t;for(a in o)r=o[a],h=this.userFields[a],h&&("text"===h&&(r=c(r),this.options.breakNewLines&&(r=r.replace(/\n/g,"<br/>"))),l=a===s?"":"="+a,u(this.userContainer,"[data-notify-"+h+l+"]").html(r));return this.updateClasses(),this.elem?this.setElementPosition():this.setGlobalPosition(),this.show(!0),this.options.autoHide?(clearTimeout(this.autohideTimer),this.autohideTimer=setTimeout(function(){return p.show(!1)},this.options.autoHideDelay)):e}},t.prototype.destroy=function(){return this.wrapper.remove()},t}(),n[C]=function(t,i,e){return t&&t.nodeName||t.jquery?n(t)[C](i,e):(e=i,i=t,new r(null,i,e)),t},n.fn[C]=function(t,i){return n(this).each(function(){var e;return e=d(n(this)).data(P),e?e.run(t,i):new r(n(this),t,i)}),this},n.extend(n[C],{defaults:l,addStyle:o,pluginOptions:N,getStyle:f,insertCSS:b}),n(function(){return b(a.css).attr("id","core-notify"),n(i).on("click","."+P+"-hidable",function(){return n(this).trigger("notify-hide")}),n(i).on("notify-hide","."+P+"-wrapper",function(){var t;return null!=(t=n(this).data(P))?t.show(!1):void 0})})})(window,document,jQuery);