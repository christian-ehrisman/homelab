// I always put my code into a self executing async function, because top level await is not allowed in JavaScript.
import { runAppleScript } from 'run-applescript';
import { readFileSync } from 'node:fs';
let appleScriptFile = ""

try {
    appleScriptFile = readFileSync("./importMe.applescript", 'utf8');
} catch (err) {
    console.error(err);
}
(async () => {
    // put the Apple Script into a string (back ticks are great for multi -line strings)
    let appleScript = appleScriptFile;

    // this will execute the Apple Script and store the result in the result variable.
    let result = await runAppleScript(appleScript);

    // do whatever you want with the result

    // at the end you always need to call returnToBTT to exit the script / return the value to BTT.
    // returnToBTT(result);
    return result;
    // it is important that this function self-executes ()
})();