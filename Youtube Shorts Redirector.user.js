// ==UserScript==
// @name Youtube Shorts Redirector
// @namespace namelessnanashi.dev
// @version 1
// @description Kill Youtube Shorts!
// @author NamelessNanashi
// @match *://www.youtube.com/shorts/*
// @run-at document-start
// @grant none
// ==/UserScript==

if (window.top !== window.self) { // Don’t run in frames.

	return;

    }

if (location.href.match('/shorts')) { // Replace Shorts

    var plainPath = location.pathname.replace (/shorts\//, "/watch?v=");
    var newURL = location.protocol + "//" +
        location.host +
        plainPath +
        location.search +
        location.hash;

    location.replace (newURL);

}
