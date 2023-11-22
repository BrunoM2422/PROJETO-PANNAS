;GRUPO: 
;BRUNO LENITTA MACHADO RA:23004288  
;LUIGI SHIMABUKURO PASTOR RA:23002634

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
    LEA DX, ESPACAMENTO
    MOV AH, 09
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
    MOV DL, ' '

    MOV [BX], DL

    POP DX
    POP BX

ENDM

.STACK 0100h

.DATA
    ; Numero de caracteres por nome = 15; ? = Numeros de caracteres digiados; 15 dup('$') = Preenche o que não foi digitado com sifrão; 4 dup (?) = Guarda os valores das provas e da média em binário
    DADOS db  5 dup(15, ?, 15 dup(' '), '$', 4 dup (?)) 

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

    PESQUISA_GERAL db 15, ?, 15 dup('$'), '$'

    LIMPA_VETOR db 15 dup(' ')

    EDITA_NOTA db 10,13,"Que prova deseja editar"
            db 10,13,"1 - P1"
            db 10,13,"2 - P2"
            db 10,13,"3 - P3$"
            
    OPCAO db "Escolha uma opcao:$"

    ESPACAMENTO db ' $'

    TITULO db  'NOME',12 DUP (' '),'P1  ','P2  ','P3 ', ' MF$'

    NOME db 10,13, "Insira o nome do aluno que deseja alterar a nota:$"

    SELECT_ALUNO db 10,13, "Qual aluno voce deseja editar?"
                 db 10,13, "Insira o ID do aluno (1 a 5):$"
    NOVA_NOTA db "Insira a nova nota da prova:$"
    
    NOVO_NOME db "Insira o novo nome do aluno:$"
.CODE

MAIN PROC
    ;Inicia os segmentos (data e extra)
    MOV AX, @DATA 
    MOV DS, AX      
    MOV ES, AX
    MOV AX, 0003H
    INT 10H
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
    
        PUSH BX
        LEA BX, DADOS + BX
        RETIRA_ENTER
        POP BX

        PULA_LINHA
        ;Guarda o valor atual de CX para que nao seja perdido
        PUSH CX       
        ;Seta o valor de CX como 3 (numero de notas de cada aluno)            
        MOV CX, 3
        ;Guarda o valor de BX na pilha
        PUSH BX      
        ;Aponta para a posicao da matriz que se encontra a primeira nota              
        MOV SI, 18        
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
                JZ SAIR_EXTRA

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
                    SAIR_EXTRA:
                    JMP SAIR
                        EDITAR_NOTA:
        	                
                            PULA_LINHA
                            ;Aponta para o vetor que fara a pesquisa do nome na matriz DADOS, le o nome que ele deve procurar na matriz e depois chama a funcao que fara a edicao na nota
                            LEA DX, PESQUISA_GERAL
                            CALL PESQUISA_NOTA

                        JMP CHAMADA_DE_MENU

                        EDITAR_NOME:
                            
                            PULA_LINHA
                            ;Aponta para o vetor que fara a pesquisa do nome na matriz DADOS, le o nome que ele deve procurar na matriz e depois chama a funcao que fara a edicao do nome
                            LEA DX, PESQUISA_GERAL
                            CALL PESQUISA_NOME
                        JMP CHAMADA_DE_MENU

                TABELA:
                    
                    PULA_LINHA
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


    PUSH SI
    PUSH BX
    XOR BX, BX                                 

    RECEBEDEC:
        ;Espera o input com a nota do usuario, caso seja um ENTER pula para o final que retornara os valores para a main
        ;Caso o valor esteja entre 0 e 9, pula para a entrada decimal, que faz sucessivas multiplicacoes por 10 para fazer a conversão para binário
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

        ;Retorna os valores dos registradores
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
    MOV SI, 18             
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
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    ;Aponta BX para DADOS
    LEA BX, DADOS
    ;Seta o contador em 5, numero de linhas da matriz
    MOV CX, 5
    LEA DX, TITULO
    PRINT

    PULA_LINHA
    
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
            ESPACO
            INC SI

        LOOP SAIDA_DE_NOTA
        ;Reitera o contador de linhas
        POP CX
        ;Pula para a próxima linha da matriz
        ADD BX, 22
        
        PULA_LINHA

    LOOP SAIDA_DE_LINHA

    POP SI
    POP DX 
    POP CX
    POP BX
    POP AX

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
    CMP AL, 10
    JAE NAO_UNICO
    ESPACO
    NAO_UNICO:
    PREPARADIV:
    XOR CX, CX                                  ;Zera CX para que possa ser contador
    MOV BX, 10                                  ;Define BX como divisor sendo 10

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

    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DX, SELECT_ALUNO
    PRINT

    XOR BX, BX

    MOV AH, 01

    PESQUISA_DE_NOME:
        INT 21H
        ;Procura o aluno pelo índice de seu ID para então procurar a sua prova respectiva e editar seu valor na matriz
        CMP AL, '1'
        JZ UM
        CMP AL, '2'
        JZ DOIS
        CMP AL, '3'
        JZ TRES
        CMP AL, '4'
        JZ QUATRO
        CMP AL, '5'
        JZ CINCO

    JMP PESQUISA_DE_NOME
        ;Com o ID do aluno, faz uma comparacao para ver qual nome sera apagado e reescrito
        ;E aponta para a linha da matriz que se encontra o nome
        UM:
        LEA BX, DADOS + 0
        JMP APAGA 

        DOIS:
        LEA BX, DADOS + 22
        JMP APAGA 

        TRES:
        LEA BX, DADOS + 44
        JMP APAGA 

        QUATRO:
        LEA BX, DADOS + 66
        JMP APAGA 

        CINCO:
        LEA BX, DADOS + 88

        APAGA:
        ;O segmento a seguir limpa o nome comparado para o input ser refeito pelo usuário
        LEA SI, LIMPA_VETOR

        LEA DI, DADOS + BX
        ADD DI, 2

        ;Limpa o nome que estava armazenado com um vetor vazio
        REP MOVSB
        ;Pede para o usuario o novo nome
        PULA_LINHA
        LEA DX, NOVO_NOME
        PRINT
        ;Le o novo nome e o coloca no lugar do antigo na matriz
        LEA DX, DADOS + BX
        CALL LEH_NOME

        PUSH BX
        LEA BX, DADOS + BX

        RETIRA_ENTER

                
        POP BX
        
    POP DI
    POP SI
    POP DX
    POP BX
    POP AX

    RET

PESQUISA_NOME ENDP

PESQUISA_NOTA PROC
    ;Guarda o valor dos registradores
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    
    LEA DX, SELECT_ALUNO
    PRINT

    XOR BX, BX

    MOV AH, 01

    PESQUISA_DE_NOTA:
       ;Procura o aluno pelo índice de seu ID para então procurar a sua prova respectiva e editar seu valor na matriz
       INT 21H

        CMP AL, '1'
        JZ UM_1
        CMP AL, '2'
        JZ DOIS_2
        CMP AL, '3'
        JZ TRES_3
        CMP AL, '4'
        JZ QUATRO_4
        CMP AL, '5'
        JZ CINCO_5

    JMP PESQUISA_DE_NOME
        ;Aponta para a linha da matriz que se encontra a nota
        UM_1:
        LEA BX, DADOS + 0
        JMP APAGA_NOTA

        DOIS_2:
        LEA BX, DADOS + 22
        JMP APAGA_NOTA

        TRES_3:
        LEA BX, DADOS + 44
        JMP APAGA_NOTA 

        QUATRO_4:
        LEA BX, DADOS + 66
        JMP APAGA_NOTA 

        CINCO_5:
        LEA BX, DADOS + 88
    
        APAGA_NOTA:

        LEA DX, EDITA_NOTA
        PRINT

        PULA_LINHA
    
        MOV AH, 01
        XOR SI, SI
        PULA_LINHA
        LEA DX, OPCAO
        PRINT
        SELECIONAR_PROVA:
            ;Pede o input para selecionar a prova que tera a nota editada
            INT 21H                                     
        
            CMP AL, '1'                                 
            JE P1                             

            CMP AL, '2'                                 
            JE P2                             

            CMP AL, '3'                                 
            JE P3       

        JMP SELECIONAR_PROVA                        
            ;Coloca em SI o espaço reservado para receber a nota  
            P1:
            PULA_LINHA
            MOV SI, 18
            JMP RECEBEPROVA

            P2:
            PULA_LINHA
            MOV SI, 19
            JMP RECEBEPROVA

            P3:
            PULA_LINHA
            MOV SI, 20

            ;O usuário escreve a prova do aluno específico que deseja reescrever, então a entrada numérica é chamada novamente, como também a média que mudará
            RECEBEPROVA:

                PULA_LINHA
                LEA DX, NOVA_NOTA
                PRINT

                CALL ENTRADA_NUM
                MOV [BX+SI], AL
                CALL MEDIA

                   
    POP SI
    POP DX
    POP BX
    POP AX  

    RET

PESQUISA_NOTA ENDP

END MAIN