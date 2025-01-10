# Contrato Abstracto Manager
El contrato Manager sirve como base para gestionar la lógica común y las configuraciones compartidas de juegos relacionados con apuestas. Es abstracto porque define funcionalidades que deben ser implementadas por contratos derivados, como Crash.

Características principales:
Uso de bibliotecas y contratos:

Usa SafeERC20 para operaciones seguras con tokens ERC20.
Integra dos interfaces externas (IHouse y IVRFManager) para interactuar con un sistema de manejo de apuestas y un administrador de números aleatorios.
Variables principales:

gameIsLive: Indica si el juego está activo o no.
minMultiplier y maxMultiplier: Definen los límites para multiplicadores en apuestas.
supportedTokenInfo: Un mapeo que almacena configuraciones específicas para cada token soportado, como:
Monto mínimo y máximo para apuestas.
Comisiones (house edge) expresadas en basis points (BP).
bets: Lista de apuestas registradas.
betMap: Mapeo que asocia un requestId (de generación de números aleatorios) con los IDs de apuestas pendientes.
Modificadores:

isVRFManager: Restringe ciertas funciones para que solo el administrador de números aleatorios (VRFManager) pueda ejecutarlas.
Eventos:

BetPlaced: Emitido al realizar una apuesta.
BetSettled: Emitido cuando una apuesta se resuelve.
BetRefunded: Emitido cuando una apuesta es reembolsada.
Funciones principales:

Configuración:
setMinMultiplier y setMaxMultiplier: Ajustan los multiplicadores mínimos y máximos permitidos.
setMinBetAmount y setMaxBetAmount: Configuran límites de apuestas para un token específico.
toggleGameIsLive: Activa o desactiva el juego.
Gestión de fondos:
withdrawCustomTokenFunds y withdrawFunds: Permiten al propietario retirar fondos en tokens o nativos.
Conversión de montos:
amountToBettableAmountConverter: Calcula el monto apostable después de deducir la comisión.
amountToWinnableAmount: Calcula el monto máximo ganable basado en el multiplicador.


Contrato Crash
El contrato Crash hereda de Manager y representa un juego de apuestas donde los jugadores eligen un multiplicador y apuestan para ganar según un resultado aleatorio generado por un sistema externo.

Características principales:
Herencia y seguridad:

Hereda funcionalidades de Manager.
Usa el modificador nonReentrant para prevenir ataques de reentrada.
Funciones principales:

placeBet:

Permite a los jugadores realizar una apuesta.
Valida que el juego esté activo y que el multiplicador elegido esté dentro de los límites.
Calcula el monto máximo ganable.
Registra la apuesta en el sistema y emite el evento BetPlaced.
settleBet:

Resuelve una o más apuestas pendientes asociadas a un requestId.
Llama a _settleBet para calcular los resultados y actualizar el estado de las apuestas.
_settleBet:

Calcula el resultado de una apuesta usando un número aleatorio (randomNumber).
Determina si el jugador gana o pierde según el multiplicador elegido y el resultado.
Actualiza el estado de la apuesta y emite el evento BetSettled.
refundBet:

Permite al propietario reembolsar una apuesta que no se haya resuelto después de un cierto número de bloques.
Calcula y devuelve el monto apostado.
Lógica específica:

La lógica del juego Crash implica un cálculo complejo para determinar si el jugador gana. Esto depende de:

H: Número aleatorio generado.
E: Factor ajustado con el multiplicador máximo.
multiplierOutcome: Multiplicador aleatorio calculado a partir de H y E.
Si el multiplicador elegido por el jugador es menor o igual al resultado (multiplierOutcome), el jugador gana el monto calculado. De lo contrario, pierde.

Resumen de roles y funciones clave:
Manager:

Gestiona configuraciones globales (tokens soportados, límites de apuestas).
Proporciona herramientas para manejar apuestas y fondos de manera genérica.
Actúa como base para contratos específicos de juegos.
Crash:

Implementa la lógica específica del juego Crash.
Permite a los jugadores interactuar directamente (realizar apuestas, resolverlas o recibir reembolsos).
Utiliza números aleatorios para determinar resultados, integrando la lógica de VRFManager.