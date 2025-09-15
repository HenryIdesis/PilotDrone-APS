# PilotDrone-APS

## O que é?
PilotDrone é uma linguagem de programação de alto nível que estou criando para controlar drones.
A ideia é que seja simples, com comandos fáceis de entender, mas que tenha as estruturas básicas de uma linguagem (variáveis, if, loops).

## Entregas
Essa é a primeira parte do projeto (entrega de 18/09).

## Linguagem estruturada
Linguagem foi estruturada no grammar.ebnf

## Exemplo

```pilotdrone
// Drone desce quando estiver com pouca bateria para evitar o risco de quedas.

var bateria = 25;

while (bateria > 0) {
    subir(5);
    girar(90);
    subir(10);
    girar(90);
    bateria = bateria - 5;
    if (bateria <= 20){
        pousar();
    }
}

