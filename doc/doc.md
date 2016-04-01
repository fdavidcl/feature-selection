---
title: "Práctica 1.b: Búsquedas por Trayectorias (Selección de características)"
subtitle: "Búsquedas locales básicas, Enfriamiento simulado, Búsqueda tabú y Búsqueda tabú extendida"
author: "Francisco David Charte Luque <<fdavidcl@correo.ugr.es>>"
date: "Grupo de prácticas 2 (Jueves 17:30 - 19:30)"
toc: yes
lang: spanish
fontsize: 11pt
geometry: "a4paper, top=2.5cm, bottom=2.5cm, left=3cm, right=3cm"
bibliography: doc/references.bib
csl: doc/ieee.csl
---

\pagebreak

# Descripción del problema

## Clasificación en Minería de Datos

El problema de clasificación consiste en, dado un conjunto de instancias ya clasificadas, aprender la suficiente información como para predecir la(s) clase(s) de nuevas instancias sin clasificar.

## Algoritmo kNN

El método de los $k$ vecinos más cercanos es uno de los más simples para tratar el problema de clasificación, y consiste en, dada una instancia a clasificar, observar la clase de las $k$ instancias que están a menor distancia (en el espacio de los atributos de entrada) y elegir la clase por votación de la mayoría. Existen diversas estrategias para realizar un desempate en caso necesario.

## Selección de características

Supongamos que tenemos un conjunto de instancias con $n$ atributos de entrada. Nos planteamos cómo afecta el tamaño de este $n$ al rendimiento de los algoritmos de clasificación.

### Problema de alta dimensionalidad

La idea de la maldición de la alta dimensionalidad consiste en que los algoritmos de clasificación empeoran su comportamiento conforme aumenta la dimensionalidad del problema ($n$). Además, este inconveniente se acentúa en el caso del algoritmo kNN, puesto que la idea del *vecino más cercano* puede perder su significado en estos casos [@Beyer1999].

### Selección de características

La selección de características es una técnica de preprocesamiento que pretende, bajo algún criterio o algoritmo, filtrar los atributos de un conjunto de datos de forma que se utilicen un grupo más limitado de ellos, es decir, utilizar $m\leq n$ atributos de los $n$ originales, tratando de no perder información. El objetivo de la selección de características es mejorar la clasificación y el tiempo de ejecución de los algoritmos.

# Consideraciones comunes a los algoritmos

## Representación de soluciones

En los algoritmos implementados se ha utilizado la representación binaria para las soluciones. Por ejemplo, si tenemos 4 características, la representación $0110$ indica que seleccionamos la segunda y la tercera.

## Función objetivo

La función objetivo, a maximizar, es la proporción de aciertos sobre el total de instancias al clasificar cada una respecto de las demás, esto es, utilizar el algoritmo kNN sobre las k instancias más cercanas distintas de la que estamos evaluando.

## Generación de vecindario

Para generar el vecindario tomamos los índices de 0 a $n-1$ y los reordenamos aleatoriamente. Vamos generando vecinos conforme vayan siendo necesarios de la siguiente manera: dado un $i\in\{0,1,\dots n-1\}$ conmutamos el bit en la $i$-ésima posición de la solución.

## Otras observaciones

### Generación de números aleatorios
Los algoritmos utilizados requieren de generadores de números aleatorios con suficiente equidistribución (esto es, que generen una distribución de probabilidad similar a la uniforme). Los generadores de números aleatorios usados en la implementación son los propios de ambos lenguajes de programación utilizados, Ruby y R. Ambos siguen el algoritmo denominado *Mersenne Twister* para generar los aleatorios [@rmersenne].

# Algoritmos empleados

## Búsquedas locales básicas



## Enfriamiento simulado

## Búsqueda tabú

## Búsqueda tabú extendida

# Algoritmo de comparación (?)

# Implementación de la práctica

## Arquitectura

## Instalación de dependencias

## Uso del programa

# Experimentación realizada

## Análisis de resultados

# Referencias
