---
title: "Práctica 1.b: Búsquedas por Trayectorias (Selección de características)"
subtitle: "Búsquedas locales básicas, Enfriamiento simulado, Búsqueda tabú y Búsqueda tabú extendida"
author: "Francisco David Charte Luque (77368864S) <<fdavidcl@correo.ugr.es>>"
date: "Grupo de prácticas 2 (Jueves 17:30 - 19:30)"
toc: yes
lang: spanish
fontsize: 11pt
geometry: "a4paper, top=2.5cm, bottom=2.5cm, left=3cm, right=3cm"
bibliography: doc/references.bib
csl: doc/ieee.csl
numbersections: yes
header-includes:
  - \usepackage{algorithmic}
  - \usepackage{algorithm}
  - \floatname{algorithm}{Algoritmo}
  - \renewcommand{\algorithmicrequire}{\textbf{Input:}}
  - \renewcommand{\algorithmicensure}{\textbf{Output:}}
  - \usepackage{pdflscape}
---

\pagebreak

# Descripción del problema

## Clasificación en Minería de Datos

El problema de clasificación consiste en, dado un conjunto de instancias ya clasificadas, realizar aprendizaje para obtener un conocimiento suficiente como para predecir la(s) clase(s) de nuevas instancias sin clasificar.

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
  \FORALL{instancia \textbf{en} dataset}
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
  \FORALL{bit \textbf{en} aleatorizar([0 ... num-características])}
    \STATE{vecino $\gets$ conmutar(solución-actual, bit)}
    \STATE{petición $\gets$ esperar-petición()}
    \STATE{responder(petición, [vecino, fitness(vecino)])}
  \ENDFOR
\end{algorithmic}
\end{algorithm}

## Otras observaciones

### Generación de números aleatorios
Los algoritmos utilizados requieren de generadores de números aleatorios con suficiente equidistribución (esto es, que generen una distribución de probabilidad similar a la uniforme). Los generadores de números aleatorios usados en la implementación son los propios del lenguaje de programación utilizado, objetos de la clase `Random` de Ruby. Siguen el algoritmo denominado *Mersenne Twister* para generar los aleatorios [@rubyrandom], que asegura una distribución suficientemente uniforme para propósito general [@Matsumoto].

### Reproducibilidad
Los resultados obtenidos son reproducibles por otros usuarios ya que se ha fijado una semilla aleatoria por defecto a 1, que se utiliza para generar las semillas aleatorias que se usarán en las distintas ejecuciones (de esta forma siempre se generan las mismas semillas).

Además, las tablas y gráficos obtenidos resultan de la ejecución del guion `stats/stats.R` que se incluye en el código fuente, a partir de los archivos CSV que se obtengan como salida del programa en `out/` y se copien en el directorio `stats/csv/`. Este mismo documento se puede generar al completo mediante el comando `rake doc`.

# Algoritmos empleados

## Búsquedas locales simples

Se ha implementado la búsqueda local de primer descenso y, adicionalmente, la búsqueda local de mayor descenso, con el objetivo de analizar si el tiempo que requiere buscar en el vecindario completo se ve compensado por una mejora en los resultados de la técnica. A continuación se describe el algoritmo base de una búsqueda por trayectorias simples y se concreta la función *siguiente-solucion()* en los siguientes algoritmos:

\begin{algorithm}
\caption{Bucle externo de una búsqueda local por trayectorias simples}
\begin{algorithmic}
  \STATE{solución-actual $\gets$ solución-aleatoria()}
  \WHILE{tenemos-soluciones-nuevas}
    \STATE{solución-actual $\gets$ siguiente-solucion(vecinos: vecindario)}
  \ENDWHILE
  \RETURN{solución-actual}
\end{algorithmic}
\end{algorithm}

\begin{algorithm}
\caption{Técnica de selección de la búsqueda local del primer descenso}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \WHILE{siguiente = \textbf{nil} \textbf{y} quedan(vecinos)}
    \STATE{vecino $\gets$ sacar(vecinos)}
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
  \WHILE{quedan(vecinos)}
    \STATE{vecino $\gets$ sacar(vecinos)}
    \IF{fitness(vecino) > mejor-encontrada}
      \STATE{siguiente $\gets$ vecino}
      \STATE{mejor-encontrada $\gets$ fitness(vecino)}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}

## Enfriamiento simulado

Para el enfriamiento simulado, se calcula la temperatura inicial en función de la calidad de la solución aleatoria inicial, siguiendo la siguiente fórmula:
$$T_{\mathrm{inicial}} = \frac{\mu\times \mathrm{fitness}(S_{\mathrm{inicial}})}{-\log(\phi)},$$
donde $\log$ es el logaritmo natural, y $\phi$ y $\mu$ son parámetros que representan el comportamiento de aceptación de una solución con cierto empeoramiento respecto de la actual. Ambos se ajustan a $0,3$ en las ejecuciones.

El esquema de enfriamiento de la temperatura es el de Cauchy modificado:
$$T_{\mathrm{siguiente}} = \frac{T}{1 + \beta\times T}\mbox{, donde }\beta=\frac{T_{\mathrm{inicial}} - T_{\mathrm{final}}}{M\times T_{\mathrm{inicial}} \times T_{\mathrm{final}}}$$
y $M$ representa el número máximo de enfriamientos a realizar.

El algoritmo \ref{simann} describe el proceso de enfriamiento del algoritmo mientras va eligiendo soluciones, mientras que el algoritmo \ref{metropolis} describe la selección de una solución mediante el criterio de Metropolis.

\begin{algorithm}
\caption{Enfriamiento simulado}
\label{simann}
\begin{algorithmic}
  \STATE{temperatura $\gets$ temperatura-inicial}
  \STATE{solución-actual $\gets$ solución-aleatoria()}
  \STATE{solución-mejor $\gets$ solución-actual}
  \STATE{hay-éxitos $\gets$ \textbf{true}}
  \WHILE{\textbf{no} enfriado() \textbf{y} hay-éxitos}
    \STATE{generados $\gets$ 0}
    \STATE{seleccionados $\gets$ 0}
    \WHILE{generados < máximo-generados \textbf{y} seleccionados < máximo-éxitos}
      \STATE{seleccionado $\gets$ \textbf{nil}}
      \STATE{seleccionado $\gets$ metropolis(vecinos: vecindario(máximo-generados $-$ generados))}
      \IF{seleccionado $\neq$ \textbf{nil}}
        \STATE{seleccionados $\gets$ seleccionados + 1}
        \STATE{solución-actual $\gets$ seleccionado}
        \IF{fitness(solución-actual) > fitness(solución-mejor)}
          \STATE{solución-mejor $\gets$ solución-actual}
        \ENDIF
      \ELSE
        \STATE{hay-éxitos $\gets$ \textbf{false}}
      \ENDIF
    \ENDWHILE
    \STATE{temperatura $\gets \frac{\mathrm{temperatura}}{1+\beta\times\mathrm{temperatura}}$}
  \ENDWHILE
  \RETURN{solución-mejor}
\end{algorithmic}
\end{algorithm}

\begin{algorithm}
\caption{Selección de una solución por criterio de Metropolis}
\label{metropolis}
\begin{algorithmic}
  \STATE{siguiente $\gets$ \textbf{nil}}
  \WHILE{siguiente = \textbf{nil} \textbf{y} quedan(vecinos)}
    \STATE{vecino $\gets$ sacar(vecinos)}
    \STATE{generados $\gets$ generados + 1}
    \STATE{diferencia $\gets$ fitness(vecino) - fitness(solución-actual)}
    \IF{diferencia $> 0$ \textbf{o} (diferencia $< 0$ \textbf{y} aleatorio() $\leq e^{\frac{\mathrm{diferencia}}{\mathrm{temperatura}}}$ )}
      \STATE{siguiente $\gets$ vecino}
    \ENDIF
  \ENDWHILE
  \RETURN{siguiente}
\end{algorithmic}
\end{algorithm}


## Búsqueda tabú

Para la búsqueda tabú, se ha desarrollado el algoritmo de una iteración usando la memoria a corto plazo (algoritmo \ref{tabu-una}), que sirve tanto para la búsqueda tabú básica (algoritmo \ref{tabu-corto}) como para la extendida (algoritmo \ref{tabu-largo}).

\begin{algorithm}
\caption{Búsqueda tabú con memoria a corto plazo}
\label{tabu-corto}
\begin{algorithmic}
  \STATE{lista-tabú $\gets$ []}
  \STATE{restantes $\gets$ máximo-iteraciones}
  \WHILE{restantes $>0$}
    \STATE{solución-actual $\gets$ iteración-corto-plazo()}
    \STATE{restantes $\gets$ restantes - 1}
  \ENDWHILE
\end{algorithmic}
\end{algorithm}

\begin{algorithm}
\caption{Iteración de memoria a corto plazo}
\label{tabu-una}
\begin{algorithmic}
  \STATE{vecinos $\gets$ vecindario(máximo-generados)}
  \STATE{actual $\gets$ \textbf{nil}}
  \FORALL{vecino \textbf{en} vecinos}
    \IF{fitness(vecino) > fitness(solución-mejor) \textbf{o} (\textbf{no} índice-modificado \textbf{en} lista-tabú \textbf{y} fitness(vecino) > fitness(actual))}
      \STATE{actual $\gets$ vecino}
    \ENDIF
  \ENDFOR
  \STATE{borrar(lista-tabú, índice-modificado)}
  \COMMENT{si el índice ya estaba en la lista, lo quitamos y colocamos al final de nuevo}
  \STATE{lista-tabú \textbf{<<} índice-modificado}
  \IF{tamaño(lista-tabú) = máximo-tamaño}
    \STATE{elimina-primero(lista-tabú)}
  \ENDIF
  \RETURN{actual}
\end{algorithmic}
\end{algorithm}


## Búsqueda tabú extendida

La búsqueda tabú con memoria a largo plazo realiza iteraciones de la anterior de forma controlada, es decir, reinicializa la búsqueda en otro lugar del espacio de soluciones cuando detecta que la búsqueda a corto plazo lleva cierto tiempo sin producir mejora. Dicha reinicialización se escoge aleatoriamente de entre una solución diversa (atendiendo a la memoria de frecuencias que se actualiza al asignar una solución), una solución aleatoria y la mejor solución encontrada.  

\begin{algorithm}
\caption{Búsqueda tabú con memoria a largo plazo}
\label{tabu-largo}
\begin{algorithmic}
  \STATE{lista-tabú $\gets$ []}
  \STATE{cuenta-atrás $\gets$ máximo-iteraciones-sin-mejora}
  \STATE{restantes $\gets$ máximo-iteraciones}
  \WHILE{restantes $>0$}
    \STATE{mejor-hasta-ahora $\gets$ fitness(solución-mejor)}
    \STATE{solución-actual $\gets$ iteración-corto-plazo()}
    \STATE{actualiza-frecuencias(solución-actual)}
    \STATE{restantes $\gets$ restantes - 1}
    \STATE{cuenta-atrás $\gets$ \textbf{if} fitness(solución-actual) > mejor-hasta-ahora \textbf{then} máximo-iteraciones-sin-mejora \textbf{else} cuenta-atrás - 1 \textbf{end if}}
    \IF{cuenta-atrás = 0}
      \STATE{lista-tabú $\gets$ []}
      \STATE{tamaño-máximo $\gets$ elige-aleatorio($0.5\times$tamaño-máximo, $1.5\times$tamaño-máximo)}
      \STATE{solución-actual $\gets$ elige-aleatorio(solución-diversa(), solución-diversa(), solución-aleatoria(), solución-mejor)}
      \STATE{cuenta-atrás $\gets$ máximo-iteraciones-sin-mejora}
    \ENDIF
  \ENDWHILE
\end{algorithmic}
\end{algorithm}


<!--# Algoritmo de comparación (?)-->

# Implementación de la práctica

La implementación de los algoritmos se ha realizado en el lenguaje Ruby, con la intención de aprovechar su expresividad a la hora de iterar de distintas formas por vectores y matrices [@enumerators], entre otras ventajas.

## Arquitectura

La aplicación tiene la estructura común de una librería Ruby (o *gema*), con los códigos fuente en el directorio `lib/` y los útiles para su ejecución en el directorio `bin/`. El algoritmo kNN está implementado en C[^knnclass] en el directorio `ext/c_knn/`, para lo cual se hace uso de la API para C de Ruby, documentada en [@anselm]. Además, las dependencias y otros metadatos están especificados en el archivo `feature-selection.gemspec` de forma que la gema sea fácil de configurar.

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

## Casos del problema y parámetros

Los conjuntos de datos dirigidos a clasificación que se han utilizado para la experimentación son los siguientes:

* *Wisconsin Diagnostic Breast Cancer* (WDBC): Un dataset binario con 30 atributos de entrada y 569 instancias. Las características representan distintos aspectos de un núcleo celular y las clases distinguen entre los benignos y los malignos.
* *Movement Libras*: Dataset multiclase (15 clases) con 90 atributos de entrada y 360 instancias. Las instancias son una extracción de datos a partir de pequeños vídeos donde se muestran signos de la lengua brasileña de signos, y la clase referencia un tipo de movimiento.
* *Arrhythmia*: Dataset multiclase (5 clases) con 278 atributos de entrada y 386 instancias. Los atributos representan diferentes datos médicos de un individuo y las clases son la ausencia de arritmia y distintos tipos de arritmia.

Los parámetros se han establecido de la siguiente forma:

* Semilla aleatoria: 1. Se utiliza para generar 10 semillas aleatorias distintas, que resultan ser 12710950, 4686060, 6762381, 12325961, 491264, 6662860, 12656262, 9554768, 7361473 y 10715281.
* Número de vecinos para kNN: 3.
* Tipo de evaluación de las heurísticas: validación cruzada 5x2
* Máximo de evaluaciones para todos los algoritmos: 15000
* Enfriamiento simulado
    * Máximo de vecinos generados por enfriamiento: $10\times n$
    * Máximo de vecinos seleccionados por enfriamiento: $n$
    * Proporción de empeoramiento ($\mu$): 0,3
    * Probabilidad de aceptación ($\phi$): 0,3
    * Temperatura final: $10^{-3}$
* Búsqueda tabú
    * Número de vecinos generados: 30
    * Tamaño inicial de la lista tabú: $\frac 1 3$

## Resumen de resultados y gráficos obtenidos

### Tablas de resultados por heurística

**Nota**: Se realizaron los paquetes de 10 ejecuciones para cada heurística y dataset en paralelo, por lo que los tiempos de ejecución se ven afectados en que las primeras ejecuciones son en general más lentas que las últimas (ya que conforme se van completando ejecuciones se libera tiempo de CPU para las heurísticas que requieren más tiempo). En una ejecución secuencial, los tiempos serían más similares a los últimos de cada tabla.

Las tablas que se incluyen en las páginas siguientes recogen la información obtenida a partir de las ejecuciones de cada heurística sobre todos los datasets. La tabla \ref{NoSelection} recoge los resultados del algoritmo 3-NN sin selección de características. Las tablas \ref{SeqForwardSelection} y \ref{SeqBackwardSelection} corresponden a los algoritmos *greedy* que sirven como punto de partida para comparar; las \ref{FirstDescent} y \ref{MaximumDescent} muestran los datos de las búsquedas locales con trayectorias simples, la tabla \ref{SimAnnealing} corresponde al enfriamiento simulado y las dos últimas, \ref{BasicTabuSearch} y \ref{TabuSearch}, a las búsquedas tabú básica y extendida respectivamente.

\begin{landscape}
\input{stats/latex/NoSelection.tex}
\input{stats/latex/SeqForwardSelection.tex}
\input{stats/latex/SeqBackwardSelection.tex}
\input{stats/latex/FirstDescent.tex}
\input{stats/latex/MaximumDescent.tex}
\input{stats/latex/SimAnnealing.tex}
\input{stats/latex/BasicTabuSearch.tex}
\input{stats/latex/TabuSearch.tex}
\clearpage

\subsubsection{Resultados globales}
La tabla \ref{global} presenta las medias de los resultados obtenidos para cada heurística:
\input{stats/latex/global.tex}
\clearpage
\end{landscape}

### Rendimiento sobre los datos de entrenamiento

\includegraphics[width=\textwidth]{stats/img/boxplot_training_wdbc.png}

\includegraphics[width=\textwidth]{stats/img/boxplot_training_movement_libras.png}

\includegraphics[width=\textwidth]{stats/img/boxplot_training_arrhythmia.png}

### Rendimiento sobre los datos de test

\includegraphics[width=\textwidth]{stats/img/boxplot_test_wdbc.png}

\includegraphics[width=\textwidth]{stats/img/boxplot_test_movement_libras.png}

\includegraphics[width=\textwidth]{stats/img/boxplot_test_arrhythmia.png}

## Análisis de resultados

De los gráficos anteriores se deduce que la tendencia general de los algoritmos es similar a lo largo de los distintos conjuntos de datos. La única excepción puede ser el buen resultado de la técnica *greedy* Sequential Forward Selection sobre el dataset Arrhythmia, que no se refleja en el resto de datasets.

Atendiendo a las técnicas *greedy*, podemos observar que, en WDBC y Movement Libras, Sequential Forward Selection optimiza mejor el resultado en la partición de entrenamiento, pero Sequential Backward Selection tiene mejor resultado en la partición de test, posiblemente porque mantiene la mayor parte de las características, mientras que SFS produce una solución con una tasa de reducción muy alta que, aunque ajustándose bien a la partición de entrenamiento, no tiene por qué ser tan adecuada para la de test. El excepcional comportamiento de SFS en Arrhythmia es más difícil de explicar, pero hemos de notar que este dataset tiene muchas más características que los otros, y por tanto la ventaja de SFS puede residir en que consigue una tasa de reducción alta, es decir, una solución con suficientes características como para realizar una buena clasificación pero sin demasiadas como para que la idea del vecino más cercano pueda perder significado, como se ha comentado previamente.

En cuanto a las búsquedas locales basadas en trayectorias simples, es notable cómo durante el entrenamiento la técnica del primer descenso obtiene mejores resultados (en el dataset Movement Libras la diferencia entre las medias es importante aunque hay mayor variabilidad en ambas técnicas), mientras que en la evaluación ambas consiguen resultados sin diferencias significativas. Esto se puede deber a que las técnicas son similares y, a partir de soluciones iniciales idénticas, llegan a máximos locales muy parecidos, que en test otorgan prácticamente los mismos resultados. Además, de los datos de tiempo observamos que la asunción previa de que la técnica del mayor descenso debía ser más lenta era incorrecta: ambas utilizan un período de tiempo similar para llegar a la solución.

Los resultados correspondientes al resto de técnicas basadas en búsqueda local tienen un aspecto clave en común, que consiste en que la mejora que consiguen para los datos de entrenamiento no se traslada de forma significativa a la evaluación con la partición de test. Esto se debe posiblemente a un sobreajuste de los algoritmos a los datos sobre los que aprenden. Una causa de que este sobreajuste se esté produciendo puede ser la definición de la función objetivo, que da mucha importancia al rendimiento de la clasificación sobre las instancias dadas, sin afinar en otros criterios que informen acerca de lo buena que es una característica independientemente de las relaciones de las instancias entre ellas. Tal vez una combinación de la función objetivo actual con una basada en Teoría de la Información nos aportaría esa doble perspectiva.

Asimismo, es interesante el hecho de que la búsqueda tabú extendida no suponga una gran mejora o incluso empeore respecto de la básica, tanto en entrenamiento como en test. Este hecho se puede deber a que las 10 iteraciones que se permiten explorar sin mejorar la solución sean pocas y se debería esperar más o modificar dinámicamente ese parámetro, ya que se provocan muchas reinicializaciones consecutivas sin mejoras. También es posible que optimizando los parámetros de la búsqueda tabú básica se consiguieran mejoras más frecuentes, de forma que a la vez obtendríamos un mejor comportamiento de la extendida.

Si comparamos con los algoritmos de referencia, el 3-NN sin selección y el SFS, la experimentación revela que hay mejoras importantes cuando se trabaja sobre los datos de entrenamiento, donde las búsquedas tabú y el enfriamiento simulado tienen ventaja sobre las demás (excepto en Arrhythmia contra SFS). Sin embargo, los resultados se nivelan más al trabajar con las particiones de test, por algunas de las causas comentadas anteriormente, principalmente el sobreajuste que producen los algoritmos con mejor rendimiento en el entrenamiento.

Los tiempos de ejecución se han visto distorsionados por el hecho de que se han realizado algunas ejecuciones en paralelo, pero aún así se puede observar que las búsquedas tabú son notablemente más lentas que el resto de algoritmos, seguidos por el enfriamiento simulado, las técnicas *greedy*, las búsquedas basadas en trayectorias simples y por último la ejecución del 3-NN. Esto indica que el enfriamiento simulado ha producido más mejora por unidad de tiempo que las búsquedas tabú, lo cual puede deberse a que estas requieren de más decisiones que pueden afectar su rendimiento a la hora de ponerlas en práctica, y en este caso no estén bien afinadas.

# Conclusiones

Los datos recogidos y el análisis realizado nos muestran que es difícil decidir qué técnica ofrece los mejores resultados: si atendemos a los datos de entrenamiento y a los tiempos, podemos afirmar que el enfriamiento simulado es muy competitivo mientras que las búsquedas tabú necesitan más tiempo para llegar a soluciones ligeramente mejores. De los datos de test no podemos deducir nada definitivo ya que las diferencias son mucho menores y la variabilidad, mayor. Se necesitaría por tanto una optimización de parámetros de algunas de las técnicas o una modificación de la función objetivo para tratar de obtener mejoras más significativas.

# Referencias