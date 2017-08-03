'use strict';

const {ipcMain} = require('electron');
const {session} = require('electron');
const path = require('path');
const edge = require('@yamachu/edge');

let edgeInitializer = edge.func({
    assemblyFile: path.join(process.env.EDGE_APP_ROOT, 'IkaLib.dll'),
    typeName: 'IkaLib.Program',
    methodName: 'Invoke',
});

let edgeInstance = edgeInitializer(null, true);

ipcMain.on('generateOauth', (event, arg) => {
    edgeInstance.generateOAuth(null, (err, result) => {
        event.sender.send('oauthGenerated', result);
    });
});

ipcMain.on('generateToken', (event, arg) => {
    edgeInstance.generateToken({
        session_token_code: arg[0],
        session_token_code_verifier: arg[1]
    }, (err, result) => {
        
        event.sender.send('tokenGenerated', result);
    });
    
});

ipcMain.on('generateIksm', (event, arg) => {
    edgeInstance.generateIksm(arg, (err, result) => {
        let sess = session.fromPartition('persist:ika');
        sess.cookies.set({ url: 'https://app.splatoon2.nintendo.net/', name: 'iksm_session', value: result }, (err) => {
            if (err) {
                console.error(err);
                return;
            }
            event.sender.send('iksmLoaded', result);
        });
    });
});
