
function Clamp(num, min, max) {
    return Math.min(Math.max(num, min), max)
}

function sortNav() {
    const sideBar = document.getElementById("navigationPanel");
    const content = document.getElementById("main");
    const navBtn = document.getElementById('closeBUT');
    console.log(navBtn.innerHTML)
    if (sideBar.style.width == "32px" || sideBar.style.width == "") {
        sideBar.style.width = "220px";
        content.style.marginLeft = "220px";
        navBtn.innerHTML = "x";
    } else {
        sideBar.style.width = "32px";
        content.style.marginLeft= "32px";
        navBtn.innerHTML = "☰";
    }
    
}

function releaseContent(content) {
    const contentHolder = document.getElementById(content)
    if (contentHolder.style.height == null || contentHolder.style.height == "0%") {
        contentHolder.style.height = 30 * (contentHolder.children.length);
    } else {
        contentHolder.style.height = "0%";
    }

}

let starting = 1
let ending = 10

function renderNewUserRows(users) {
    for (let i = starting; ending; i++) {
        const userData = users[i]
        console.log(userData)
    }
}

function continueUserRows( users, shouldGoBack ) {
    if (shouldGoBack) {
        starting = Clamp( starting + 10, 1, users.length )
        ending = Clamp( ending + 10, 1, users.length )
    } else {
        starting = Clamp( starting - 10, 1, users.length )
        ending = Clamp( ending - 10, 1, users.length )
    }
}