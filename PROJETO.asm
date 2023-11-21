.MODEL SMALL

PULA_LINHA MACRO

    ; Salva os valores de DX e AX para pular uma linha e depois os retorna

    PUSH DX 
    PUSH AX
    MOV DL, 10
    MOV AH, 02
    INT 21H
    POP AX
    POP DX
ENDM

PRINT MACRO

    ; Salva o valor de AX e imprime o que foi colocado em DX para imprimir uma string. Depois, retorna o valor de AX

    PUSH AX
    MOV AH, 09
    INT 21H
    POP AX

ENDM

ESPACO MACRO

    ; Guarda os valores de AX e DX para dar um espaçamento pela tabela usando o símbolo do sifrão, depois os retorna

    PUSH AX
    PUSH DX
    MOV AH, 02
    MOV DL, "$"
    INT 21H

    POP DX
    POP AX

ENDM

RETIRA_ENTER MACRO

    ; Guarda os valores de BX e DX, depois recebe o numero de caracteres digitados menos o ENTER, que se transforma em uma sifrão para não interferir nos valores da string ou da matriz, depois retorna os registradores

    PUSH BX
    PUSH DX

    INC BX
    MOV DL, [BX]
    INC BX
    ADD BX, DX
    MOV DL, '$'

    MOV [BX], DL

    POP DX
    POP BX

ENDM

.STACK 0100h

.DATA
; Numero de caracteres por nome = 15; ? = Numeros de caracteres digiados; 15 dup('$') = Preenche o que não foi digitado com sifrão; 4 dup (?) = Guarda os valores das provas e da média em binário
    DADOS db  5 dup(15, ?, 15 dup('$'),'$', 4 dup (?)) 

    msg1 db "INSIRA O NOME DO ALUNO:$"

    msg2 db "INSIRA A NOTA DO ALUNO:$"

    MENU db 10,13,"O que deseja fazer?"
         db 10,13,"1 - Editar Dados"
         db 10,13,"2 - Ver Tabela"
         db 10,13,"0 - Finalizar Programa$"
        
    EDICOES db 10,13,"O que deseja editar?"
             db 10,13,"1 - Editar Notas"
             db 10,13,"2 - Editar Nomes"
             db 10,13,"0 - Retornar ao Menu Principal$", 10,13

    PESQUISA_GERAL db 15, ?, 15 dup('$')

    LIMPA_VETOR db 15 dup('$')

    EDITA_NOTA db "Que prova deseja editar"
            db 10,13,"1 - P1"
            db 10,13,"2 - P2"
            db 10,13,"3 - P3$"
    OPCAO db "Escolha uma opcao:$"

.CODE

MAIN PROC
    ;Inicia os segmentos (data e extra)
    MOV AX ,@DATA 
    MOV DS,AX      
    MOV ES, AX

    ;Zera BX para garantir que a matriz estará no elemento 0,0 quando for iniciada
    XOR BX, BX     
    ;Seta o contador em 5 (numero de alunos)    
    MOV CX, 5           

    LEITURA_NOME:
        ;Zera SI para garantir que a matriz estará no primeiro valor das colunas
        XOR SI, SI      
    
        PULA_LINHA 

        LEA DX, msg1    
       
        PRINT
        ;Aponta DX para a matriz de dados na sua posição de elemento equivalente (BX)
        LEA DX, DADOS + BX
     
        CALL LEH_NOME
    
        PULA_LINHA
        ;Guarda o valor atual de CX para que nao seja perdido
        PUSH CX       
        ;Seta o valor de CX como 3 (numero de notas de cada aluno)            
        MOV CX, 3
        ;Guarda o valor de BX na pilha
        PUSH BX      
        ;Aponta para a posicao da matriz que se encontra a primeira nota              
        MOV SI, 15              
        ;Devolve o valor de BX
        POP BX             

      
        LEITURA_NOTA:
         
            LEA DX, msg2
            PRINT
           
            CALL LEH_NOTA
        
        LOOP LEITURA_NOTA
    ;Devolve o Valor de CX para que seja executado 5 vezes a leitura de nome e notas
    POP CX
    
    CALL MEDIA
    ;Soma em BX o numero da posicao dos dados do proximo aluno
    ADD BX, 22
    ;Faz a repeticao ate que CX seja 0
    LOOP LEITURA_NOME
    
    CHAMADA_DE_MENU:

        PULA_LINHA
        
        LEA DX, MENU
        PRINT

        PULA_LINHA
        
        LEA DX, OPCAO
        PRINT
        ;Espera o input do usuario, caso seja 1, o usuario podera editar as notas ou o nome
        ;caso seja 2, o usuario podera visualizar a tabela com os nomes e as notas
        ; caso seja 0, finaliza o programa
        MOV AH, 01
            ;Compara o input para saber qual funcao será executada
            SELECIONAR_OPCAO:
                INT 21H

                CMP AL, '1'
                JZ EDITAR

                CMP AL, '2'
                JZ TABELA

                CMP AL, '0'
                JZ SAIR

            JMP SELECIONAR_OPCAO

                EDITAR:

                    PULA_LINHA
                    ;Aponta para o menu das edições de nome e nota
                    LEA DX, EDICOES
                    PRINT

                    PULA_LINHA

                    LEA DX, OPCAO
                    PRINT
                    ;Espera o input do usuario, caso seja 1, o usuario podera editar as notas 
                    ;caso seja 2, o  o usuario podera editar os nomes 
                    ;caso seja 0, retorna ao menu principal
                    MOV AH, 01
    
                    SELECIONAR_PESQUISA:

                        INT 21H


                        CMP AL, '1'
                        JZ EDITAR_NOTA

                        CMP AL, '2'
                        JZ EDITAR_NOME

                        CMP AL, '0'
                        JZ CHAMADA_DE_MENU

                    JMP SELECIONAR_PESQUISA

                        EDITAR_NOTA:
        	                ;Aponta para o vetor que fara a pesquisa do nome na matriz DADOS, le o nome que ele deve procurar na matriz e depois chama a funcao que fara a edicao na nota
                            LEA DX, PESQUISA_GERAL
                            CALL LEH_NOME
                            INC DX

                            CALL PESQUISA_NOTA

                        JMP CHAMADA_DE_MENU

                        EDITAR_NOME:
                            ;Aponta para o vetor que fara a pesquisa do nome na matriz DADOS, le o nome que ele deve procurar na matriz e depois chama a funcao que fara a edicao do nome
                            LEA DX, PESQUISA_GERAL
                            CALL LEH_NOME
                            INC DX

                            CALL PESQUISA_NOME
                        JMP CHAMADA_DE_MENU

                TABELA:
                    ;Chama a funcao que imprimirá a tabela
                    PULA_LINHA

                    CALL IMPRIME_TABELA
                ;Volta para o menu principal 
                JMP CHAMADA_DE_MENU

                SAIR:   
                    ;Finaliza o programa
                    MOV AH, 4CH
                    INT 21H

MAIN ENDP

LEH_NOME PROC
    ;Guarda o valor de AX na pilha
    PUSH AX
    ;Faz a leitura da string 
    MOV AH, 0AH
    INT 21H
    ;Retorna o valor de AX 
    POP AX
    ;Retorna a string lida
    RET

LEH_NOME ENDP

LEH_NOTA PROC
    ;Guarda o valor de BX na pilha
    PUSH BX
    ;Aponta para BX o elemento da matriz que será usado para guardar a nota
    LEA BX, DADOS + BX

    CALL ENTRADA_NUM
    ;Move o valor lido para sua posição dentro da matriz
    MOV [BX + SI], AL
    ;Incrementa SI para passar para a próxima nota que será lida
    INC SI
    ;Retorna o valor de BX
    POP BX

    RET

LEH_NOTA ENDP

ENTRADA_NUM PROC

    ;Guarda o valor de SI na pilha
    PUSH SI
    ;Guarda o valor de BX na pilha
    PUSH BX
    ;Zera BX para nao conter lixo
    XOR BX, BX                                 

    RECEBEDEC:
        ;Espera o input com a nota do usuario, caso seja um ENTER pula para o final que retornara os valores para a main
        ;Caso o valor esteja entre 0 e 9, pula para a entrada decimal, que faz sucessivas multiplicacoes por 10 para fazer a conversao 
        MOV AH, 01                                  
        INT 21H                                     

        CMP AL, 13                                  
        JE ENTDECFIM                              

        CMP AL, '0'                               
        JB RECEBEDEC                            

        CMP AL, '9'                                
        JA RECEBEDEC                                
        ;Faz a conversao
        DECPARABIN:
            XOR AH, AH                                 

            AND AL, 0FH                                 
            PUSH AX                                     

            MOV AX, 10                               
            MUL BX                                     
            POP BX                                     
            ADD BX, AX                                  
    
    JMP RECEBEDEC                               

    ENTDECFIM:

        MOV AX, BX                                  

        POP BX
        POP SI

        RET

ENTRADA_NUM ENDP

MEDIA PROC
    ;Guarda o valor de CX
    PUSH CX              
    ;Seta o contador em 3 (numero de notas)        
    MOV CX, 3
    ;Guarda o valor de BX
    PUSH BX                 
    ;Faz com que SI esteja na posicao da primeira nota    
    MOV SI, 15              
    ;Devolve o valor de BX
    POP BX             
    ;Zera AX para que nao tenha lixo
    XOR AX, AX
    ;Guarda o valor de BX novamente
    PUSH BX
    ;Aponta para BX o elemento que será usado no calculo
    LEA BX, DADOS + BX

    SOMA_DA_MEDIA:
        ;Faz a soma das notas, incrementando 1 em SI para que pegue a proxima nota
        ADD AL, [BX + SI]
        INC SI

    LOOP SOMA_DA_MEDIA
    ;Guarda o valor de BX, que sera usado para fazer a divisao das notas
    PUSH BX
    ;Zera DX para que nao tenha lixo e altere a media
    XOR DX, DX

    ;Seta BX em 3 para que a divisao seja feita por 3
    MOV BX, 3
    DIV BX

    ;Devolve o valor de BX
    POP BX

    ;Move AL para o local destinado a media do aluno na matriz DADOS   
    MOV [BX + SI], AL

    ;Devolve os valores de BX e CX
    POP BX
    POP CX
    
    ;Retorna os valores para a main
    RET
MEDIA ENDP

IMPRIME_TABELA PROC 
    ;Aponta BX para DADOS
    LEA BX, DADOS
    ;Seta o contador em 5, numero de linhas da matriz
    MOV CX, 5

    SAIDA_DE_LINHA:
        ;Aponta SI para o valor da primera nota que será impressa
        MOV SI, 18
        ;Move o valor do elemento da matriz para imprimir o nome guardado naquela posição
        MOV DX, BX
        ADD DX, 2

        MOV AH, 09
        ;Imprime o nome
        INT 21H

        ESPACO

        ;Guarda o contador de linhas
        PUSH CX
        ;Contador de notas que serão impressas
        MOV CX, 4

        SAIDA_DE_NOTA:
    
            CALL SAIDA_DECIMAL

            ESPACO

            INC SI

        LOOP SAIDA_DE_NOTA
        ;Reitera o contador de linhas
        POP CX
        ;Pula para a próxima linha da matriz
        ADD BX, 22
        PULA_LINHA

    LOOP SAIDA_DE_LINHA

    RET

IMPRIME_TABELA ENDP

SAIDA_DECIMAL PROC
    ;Guarda os valores dos registradores
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ;Zera AX que receberá a nota que será convertida para número e então impressa
    XOR AX, AX
    MOV AL, [BX+SI]

    DIVISAO:
        ;Contador que será incrementado toda vez que uma divisão acontecer para garantir que todos os dígitos do número serão impressos
        XOR CX, CX
        ;Move o divisor 
        MOV BX, 10

        NUMEROS:
            ;DX receberá o resto da divisão
            XOR DX, DX

            DIV BX
            ;Guarda o resto na pilha
            PUSH DX
            ;Incrementa o contador de dígitos que serão impressos
            INC CX

            OR AX, AX

            JNZ NUMEROS

            MOV AH, 02

            IMPRIMIR_NUMEROS:
                ;Imprime o resto da divisão, transformando o caractere em número no processo
                POP DX
                OR DX, 30H
                INT 21H

            LOOP IMPRIMIR_NUMEROS
    ;Retorna os valores dos registradores
    POP DX
    POP CX
    POP BX
    POP AX

    RET

SAIDA_DECIMAL ENDP

PESQUISA_NOME PROC
    ;Guarda os valores dos registradores
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI

    XOR AL, AL
    ;Contador usado para comparar todos os 5 nomes da matriz com o que foi digitado
    MOV CX, 5

    XOR BX, BX

    PESQUISA_DE_NOME:
        PUSH DX
        ;Guarda o contador
        PUSH CX

        ;Aponta para o que foi digitado para pesquisa pelo usuário
        LEA SI, PESQUISA_GERAL + 2
        LEA DI, DADOS + BX
        ADD DI, 2

        PUSH BX
        MOV BX, DX
        MOV CL, [BX]
        POP BX

        ;Compara a string armazenada dígito por dígito com a que foi digitada pelo usuário
        REPE CMPSB
        JNZ STR_NAO_EH_IGUAL

        ;O segmento a seguir limpa a parte da matriz com o nome comparado para o input ser refeito pelo usuário
        LEA SI, LIMPA_VETOR

        LEA DI, DADOS + BX
        ADD DI, 2

        PUSH BX
        MOV BX, DX
        MOV CL, [BX]
        POP BX

        ;Limpa o nome que estava armazenado com um vetor vazio
        REP MOVSB

        LEA DX, DADOS + BX
        CALL LEH_NOME

        PUSH BX
        LEA BX, DADOS + BX

        RETIRA_ENTER

        POP BX

        JMP PROXIMA_LINHA

        ;Caso ela não seja exatamente igual com a linha que está sendo comparada, passa para a próxima até que a matriz armazenada acabe
        STR_NAO_EH_IGUAL:

            INC AL

        PROXIMA_LINHA:

            ADD BX, 22
            POP CX
            POP DX

    LOOP PESQUISA_DE_NOME
    ;Checa se todas as linhas da matriz com nomes foram comparadas
    CMP AL, 5
    JNE FINAL_DA_PESQUISA


    FINAL_DA_PESQUISA:
        ;Retorna os valores dos registradores
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX

    RET

PESQUISA_NOME ENDP

PESQUISA_NOTA PROC
   ;Guarda os valores dos registradores
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI

    XOR AL, AL
                
    MOV CX, 5
                
    XOR BX, BX

    PESQUISA_DE_NOTA:

        PUSH DX

        PUSH CX

        LEA SI, PESQUISA_GERAL + 2

        LEA DI, DADOS + BX

        ADD DI, 2
                    
        PUSH BX
        MOV BX, DX
        MOV CL, [BX]
        POP BX
                        
        REPE CMPSB
        JNZ NOT_EQUAL_NOME
                    
        PUSH BX

        LEA BX, TABELA + BX

        LEA DX, EDITA_NOTA

        PRINT

        PULA_LINHA

        MOV AH, 01
        XOR SI, SI

        SELECIONAR_PROVA:

            INT 21H                                     

            CMP AL, '1'                                 
            JE P1                             

            CMP AL, '2'                                 
            JE P2                             

            CMP AL, '3'                                 
            JE P3       

        JMP SELECIONAR_PROVA                         
            
            P1:
            ADD SI, 19
            JMP RECEBEPROVA

            P2:
            ADD SI, 20
            JMP RECEBEPROVA

            P3:
            ADD SI, 21

            RECEBEPROVA:

                CALL ENTRADA_NUM
                MOV [BX+SI], AL
                POP BX
                CALL MEDIA
                                
            JMP PESQUISA_NOTA_FIM

            NOT_EQUAL_NOME:

                INC AL

            PESQUISA_NOTA_FIM:

                ADD BX, 22
                POP CX
                POP DX

    LOOP PESQUISA_DE_NOTA
                    
        CMP AL, 5
        JNE FINAL
                    
    FINAL:                
        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX

    RET

PESQUISA_NOTA ENDP

END MAIN