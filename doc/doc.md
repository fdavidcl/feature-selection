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
header-includes:
  - \usepackage{algorithmic}
  - \usepackage{algorithm}
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

\begin{algorithm}
\caption{Cálculo de la función objetivo}
\begin{algorithmic}
  \STATE{aciertos $\gets$ 0}
  \FORALL{instancia en dataset}
    \STATE{predicción $\gets$ predecir-kNN(instancia, dataset$\setminus$\{instancia\})}
    \IF{predicción = clase(instancia)}
      \STATE{aciertos $\gets$ aciertos$+ 1$}
    \ENDIF
  \ENDFOR
  \RETURN{aciertos/longitud(dataset)}
\end{algorithmic}
\end{algorithm}

## Generación de vecindario

Para generar el vecindario, obtenemos vecinos mientras sean necesarios conmutando un bit aleatorio de la solución actual:

\begin{algorithm}
\caption{Generación a demanda de vecindario de una solución}
\begin{algorithmic}
  \FORALL{bit in aleatorizar([0 ... num-características])}
    \STATE{vecino $\gets$ conmutar(solución-actual, bit)}
    \STATE{petición $\gets$ esperar-petición()}
    \STATE{responder(petición, [vecino, fitness(vecino)])}
  \ENDFOR
\end{algorithmic}
\end{algorithm}

## Otras observaciones

### Generación de números aleatorios
Los algoritmos utilizados requieren de generadores de números aleatorios con suficiente equidistribución (esto es, que generen una distribución de probabilidad similar a la uniforme). Los generadores de números aleatorios usados en la implementación son los propios de ambos lenguajes de programación utilizados, Ruby y R. Ambos siguen el algoritmo denominado *Mersenne Twister* para generar los aleatorios [@rmersenne][@rubyrandom], que asegura una distribución suficientemente uniforme para propósito general [@Matsumoto].

# Algoritmos empleados

## Búsquedas locales simples

Se ha implementado la búsqueda local de primer descenso y, adicionalmente, la búsqueda local de mayor descenso, con el objetivo de analizar si el tiempo que requiere buscar en el vecindario completo se ve compensado por una mejora en los resultados de la técnica. A continuación se describe el algoritmo base de una búsqueda por trayectorias simples y se concreta la función *siguiente-solucion()* en los siguientes algoritmos:

\begin{algorithm}
\caption{Bucle externo de una búsqueda local por trayectorias simples}
\begin{algorithmic}
  \STATE{solución-actual $\gets$ solución-aleatoria()}
  \WHILE{tenemos-soluciones-nuevas}
    \STATE{solución-actual $\gets$ siguiente-solucion()}
  \ENDWHILE
  \RETURN{solución-actual}
\end{algorithmic}
\end{algorithm}

\begin{algorithm}
\caption{Técnica de selección de la búsqueda local del primer descenso}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \WHILE{es-nil(siguiente)}
    \STATE{vecino $\gets$ nuevo-vecino()}
    \IF{fitness(vecino) > fitness(solución-actual)}
      \STATE{siguiente $\gets$ vecino}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}

\begin{algorithm}
\caption{Técnica de selección de la búsqueda local del máximo descenso}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \STATE{mejor-encontrada $\gets$ fitness(solución-actual)}
  \WHILE{quedan-vecinos}
    \STATE{vecino $\gets$ nuevo-vecino()}
    \IF{fitness(vecino) > mejor-encontrada}
      \STATE{siguiente $\gets$ vecino}
      \STATE{mejor-encontrada $\gets$ fitness(vecino)}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}

## Enfriamiento simulado


\begin{algorithm}
\caption{Técnica de selección de la búsqueda local del máximo descenso}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \STATE{mejor-encontrada $\gets$ fitness(solución-actual)}
  \WHILE{quedan-vecinos}
    \STATE{vecino $\gets$ nuevo-vecino()}
    \IF{fitness(vecino) > mejor-encontrada}
      \STATE{siguiente $\gets$ vecino}
      \STATE{mejor-encontrada $\gets$ fitness(vecino)}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}


## Búsqueda tabú


\begin{algorithm}
\caption{Técnica de selección de la búsqueda local del máximo descenso}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \STATE{mejor-encontrada $\gets$ fitness(solución-actual)}
  \WHILE{quedan-vecinos}
    \STATE{vecino $\gets$ nuevo-vecino()}
    \IF{fitness(vecino) > mejor-encontrada}
      \STATE{siguiente $\gets$ vecino}
      \STATE{mejor-encontrada $\gets$ fitness(vecino)}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}


## Búsqueda tabú extendida


\begin{algorithm}
\caption{Técnica de selección de la búsqueda local del máximo descenso}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \STATE{mejor-encontrada $\gets$ fitness(solución-actual)}
  \WHILE{quedan-vecinos}
    \STATE{vecino $\gets$ nuevo-vecino()}
    \IF{fitness(vecino) > mejor-encontrada}
      \STATE{siguiente $\gets$ vecino}
      \STATE{mejor-encontrada $\gets$ fitness(vecino)}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}


<!--# Algoritmo de comparación (?)-->

# Implementación de la práctica

La implementación de los algoritmos se ha realizado en el lenguaje Ruby, con la intención de aprovechar su expresividad a la hora de iterar de distintas formas por vectores y matrices, entre otras ventajas.

## Arquitectura

La aplicación tiene la estructura común de una librería Ruby (o *gema*), con los códigos fuente en el directorio `lib/` y los útiles para su ejecución en el directorio `bin/`. El algoritmo kNN está implementado en C[^knnclass] en el directorio `ext/c_knn/`. Además, las dependencias y otros metadatos están especificados en el archivo `feature-selection.gemspec` de forma que la gema sea fácil de configurar.

[^knnclass]: La implementación de kNN se ha adaptado del código C del paquete `class` [@rclass] para R.

En lo referente a la implementación, se ha desarrollado una sencilla jerarquía de clases que permitan facilitar el desarrollo y la experimentación. Las clases base son `Heuristic`, de la que derivan todas las técnicas implementadas; `Classifier`, de la que deriva el clasificador kNN (y que permitiría implementar otros clasificadores adicionales); `Evaluator`, que se encarga de la evaluación por validación cruzada de las heurísticas, y `Dataset`, que encapsula los conjuntos de datos utilizados. Adicionalmente se utilizan las clases auxiliares `Config` y `ARFFFile`.

Para las técnicas basadas en trayectorias simples y las basadas en búsqueda local se ha desarrollado una base común en las clases `MonotonicSearch` y `LocalSearch`. La primera implementa todo lo necesario para una búsqueda local de ascensión de pendientes, tanto el bucle externo como la generación del vecindario. Únicamente la extracción de la próxima solución del vecindario se deja a las clases `FirstDescent` y `MaximumDescent`. Además, `LocalSearch` añade la funcionalidad necesaria para llevar un registro de la mejor solución global y sirve como base para el enfriamiento simulado (`SimAnnealing`) y las búsquedas tabú (`BasicTabuSearch`, `TabuSearch`).

## Instalación y configuración

### Automática (Linux)

En sistemas Linux (y posiblemente OS X) basta con ejecutar `bin/setup` en un terminal bash. Este guion revisará las dependencias del programa, y es capaz de instalar una versión actual de Ruby para la ejecución de las pruebas.

Es necesario tener previamente instalados los paquetes básicos de desarrollo (por ejemplo `build-essential` en el caso de las distribuciones basadas en Ubuntu).

### Manual (todos los sistemas)

Será necesario contar con una versión reciente de Ruby (recomendablemente la 2.3.0) y el paquete de desarrollo de Ruby (para las dependencias con extensiones nativas en C). Instalaremos manualmente la gema *bundler* mediante `gem install bundler`. Cuando se haya instalado, ejecutamos `bundle` para instalar el resto de dependencias. Tras esto, compilamos el código C mediante `rake compile` y el programa ya estará listo para usarse.

### Archivo de configuración

El archivo donde se almacenan los parámetros del programa es `config.yml`. Se puede generar un archivo de configuración por defecto con `bin/config`, o bien se generará automáticamente en la primera ejecución del programa, si no existe. En el archivo se puede activar la salida de información por pantalla con el parámetro `:debug` a `true`. Por defecto, todos los parámetros se ajustan a los definidos en el guion de prácticas.

## Uso del programa

El guion `bin/start` realiza las ejecuciones de todos los algoritmos sobre todos los datasets con la validación cruzada 5x2 y guarda los resultados en ficheros CSV en el directorio `out/`. Se puede editar fácilmente para ejecutar selectivamente algunos algoritmos o usar alguno de los datasets.

# Experimentación realizada

## Análisis de resultados

# Referencias
