package ece351.util;

import java.lang.Character;
import java.lang.StringBuilder;
import java.util.Arrays;

public final class Lexer {

    private enum Kind {
        SIMPLE,
        ID,
        KEYWORD,
        EOF,
    }

    private enum State {
        START,
        CONTINUE_ID,
        CONTINUE_ASSIGN,
    }

    private final char[] input;
    private int index;
    private Kind kind;
    private String token;

    public Lexer(final String input) {
        this.input = input.toCharArray();
        this.index = 0;
        advance();
    }

    private boolean isContinueID(char ch) {
        return (Character.isLetter(ch) || Character.isDigit(ch) || ch == '_');
    }

    public void advance() {
        StringBuilder stringBuilder = new StringBuilder();
        State state = State.START;
        kind = Kind.SIMPLE;

        if (index == input.length) {
            kind = Kind.EOF;
        }

        while (index < input.length) {
            char ch = input[index];
            ++index;

            if (state == State.START) {
                if (Character.isWhitespace(ch)) {
                    // We may have got to the end by ignoring whitespace
                    if (index == input.length) {
                        kind = Kind.EOF;
                    }
                    continue;
                }
                else if (Character.isLetter(ch)) {
                    kind = Kind.ID;
                    state = State.CONTINUE_ID;
                }
                else if (ch == '<') {
                    state = State.CONTINUE_ASSIGN;
                }
            }
            else if (state == State.CONTINUE_ID) {
                if (!isContinueID(ch)) {
                    --index;
                    break;
                }
            }
            else if (state == State.CONTINUE_ASSIGN) {
                if (ch == '=') {
                    state = State.START;
                }
                else {
                    --index;
                    break;
                }
            }
            stringBuilder.append(ch);
            if (state == State.START) {
                break;
            }
        }
        token = stringBuilder.toString();
        if (token.equals("and") || token.equals("or") || token.equals("not")) {
            kind = Kind.KEYWORD;
        }
    }

	/**
	 * Checks to see whether String s is equal to the current token. Returns
	 * true if they are equal, otherwise it will return false.
	 * 
	 * @param s
	 * @return true if the current token equals parameter s
	 */
    public boolean inspect(final String s) {
        return token.equals(s);
    }

	/**
	 * Takes an array of strings and checks if the one of the elements inside
	 * the array are equal to the current token.
	 * 
	 * @param options
	 * @return true if any of the elements inside the array matches the token,
	 *         otherwise it will return false.
	 */
    public boolean inspect(final String... options) {
        for (final String s : options) {
            if (inspect(s)) {
                return true;
            }
        }
        return false;
    }

	/**
	 * Checks to see if the current token is an ID i.e. the pin name.
	 * 
	 * @return true if the current token is an ID, otherwise it will return
	 *         false.
	 */
    public boolean inspectID() {
        return kind == Kind.ID;
    }

	/**
	 * Checks to see if the lexer has reached the end of the file.
	 * 
	 * @return returns true if it is the end of file, otherwise it will return
	 *         false.
	 */
    public boolean inspectEOF() {
        return kind == Kind.EOF;
    }

	/**
	 * If String s matches the current token then the token is consumed,
	 * parameter s is returned, then the lexer advances to the next token.
	 * 
	 * @param s
	 * @return returns parameter s if parameter s equals the current token,
	 *         otherwise returns null and outputs an error
	 */
    public String consume(final String s) {
        if (token.equals(s)) {
            advance();
            return s;
        }
        else {
            err("expected: '" + s + "' got '" + token + "'");
            return null; // dead code
        }
    }

	/**
	 * Takes an array of strings. If any of the elements in the array matches
	 * the token, the token is consumed, and the lexer advances to the next
	 * token
	 * 
	 * @param options
	 * @return the element matching the current token from parameter options,
	 *         otherwise returns null and outputs an error
	 */
    public String consume(final String... options) {
        for (final String s : options) {
            if (inspect(s)) {
                return consume(s);
            }
        }
        err("expected one of '" + Arrays.toString(options) + "' but had '"
            + token + "'");
        return null;
    }

	/**
	 * Consumes the ID and advances to the next token
	 * 
	 * @return string of ID is returned, otherwise returns null and outputs an
	 *         error
	 */
    public String consumeID() {
        if (!inspectID()) err("expected: ID got '" + token + "'");
        final String result = token;
        advance();
        return result;
    }

	/**
	 * Consumes the end of file, otherwise an error is thrown.
	 */
    public void consumeEOF() {
        if (!inspectEOF()) err("expected: EOF");
        advance();
    }

	/**
	 * @return Returns the current value of the token.
	 */
    public String debugState() {
        return token;
    }
    
    protected void err(final String msg) {
        Debug.barf(msg);
    }

}
