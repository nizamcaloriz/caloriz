// Import the functions you need from the SDKs you need
import { initializeApp, getApps, getApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyDUj77h-LeMqTSqlLvyU3YFeiAZuprxfdc",
    authDomain: "caloriz-c538f.firebaseapp.com",
    projectId: "caloriz-c538f",
    storageBucket: "caloriz-c538f.firebasestorage.app",
    messagingSenderId: "878452415028",
    appId: "1:878452415028:web:9284db072fef990eb60861",
    measurementId: "G-WRVDCG5P59"
};

// Initialize Firebase
const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
const db = getFirestore(app);
const auth = getAuth(app);

export { db, auth };
