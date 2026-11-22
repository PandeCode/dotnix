// firefox has chrome.* too, so one script serves both browsers
chrome.commands.onCommand.addListener((command, tab) => {
  if (command === "close-tab" && tab) {
    chrome.tabs.remove(tab.id);
  }
});
