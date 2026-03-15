Il dispositivo CN-03 è un contatore senza segno a 8 bit che può essere interrogato da un master mediante un’interfaccia SPI comprensiva
del segnale chip select (CS). 
Il dispositivo invia al master il valore del contatore attuale contemporaneamente alla ricezione di un valore a 8 bit da quest’ultimo. 
Se il bit più significativo del valore ricevuto dal master è 1 il dispositivo CN-03 incrementa il contatore, se è 0 lo imposta al
valore dato dai restanti 7 bit (con zero-extension a 8-bit). 
Il master inizia una transazione abbassando il livello della linea CS, normalmente alta, trasmette uno dei possibili comandi e riceve
il valore del conteggio, infine riporta la linea CS al valore alto.

    - Scrivere un modulo SystemVerilog che descriva il dispositivo CN-03. 
    Scrivere un testbench che includa una lettura con reset, una con incremento e una con impostazione del valore 0x50.
    
    - Scrivere un programma bare metal in assembly ARM 32 o in linguaggio C per Raspberry Pi 3B+ per controllare il dispositivo CN-03 
    tramite la sua interfaccia SPI. Utilizzare i pin GPIO 8 (Chip select), 11 (Clock), 10 (MOSI) e MISO (GPIO9) per connettere lo 
    slave e implementare un driver bit-banging con frequenza di clock di 100 KHz.
    Il programma deve fare in modo che il dispositivo CN-03 resetti il contatore, lo incrementi fino a 100, lo imposti al massimo
    e lo incrementi una volta, ripetendo la sequenza in un ciclo senza fine. 
    Il programma deve inoltre visualizzare ciascun valore ricevuto tramite la subroutine display 8bit value
    
    - Studiare la possibilità di sintetizzare il dispositivo