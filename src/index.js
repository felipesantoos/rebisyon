const electron = require('electron');
const { app, BrowserWindow, ipcMain } = electron;
const path = require('path');
var sqlite3 = require('sqlite3').verbose();

// Handle creating/removing shortcuts on Windows when installing/uninstalling.
if (require('electron-squirrel-startup')) { // eslint-disable-line global-require
  app.quit();
}

let mainWindow;

const createWindow = () => {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    }
  });

  // and load the index.html of the app.
  mainWindow.loadFile(path.join(__dirname, 'index.html'));
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and import them here.

const dbPath = path.resolve(__dirname, 'db/rebisyon.db')
var db = new sqlite3.Database(dbPath);
const database = require('./js/back/db.js');

ipcMain.on("rqtGetDks", (event) => {
  database.getDks(db, function (err, rows)  {
    if(err == null) {
      mainWindow.webContents.send("rcvGetDks", rows);
    } else {
      mainWindow.webContents.send("error");
    }
  });
});

ipcMain.on("rqtGetCdsNbr", (event, state) => {
  database.getCdsCnt(db, state, function (err, row) {
    if(err == null) {
      mainWindow.webContents.send("rcvGetCdsNbr", state, row);
    } else {
      mainWindow.webContents.send("error");
    }
  });
});

ipcMain.on("rqtAddDk", (event, name) => {
  database.addDk(db, name, function (err, rows) {
    database.getLstDkId(db, function (err, rows) {
      if(err == null) {
        mainWindow.send("rcvAddDk", rows);
      } else {
        mainWindow.webContents.send("error");
      }
    })
  });
});

ipcMain.on("rqtRmDk", (event, id) => {
  database.rmDk(db, id, function (err) {
    if(err == null) {
      mainWindow.webContents.send("rcvRmDk", id);
    } else {
      mainWindow.webContents.send("error");
    }
  });
})
