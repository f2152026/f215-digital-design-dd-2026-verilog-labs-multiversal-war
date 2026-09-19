module tb;

  reg [3:0] t_a;
  reg [3:0] t_b;
  reg       t_op;

  wire [3:0] t_result;

  integer errors;

  alu DUT (
    .a(t_a),
    .b(t_b),
    .op(t_op),
    .result(t_result)
  );

  task check;
    input [3:0] expected;
    begin
      #1;
      if (t_result !== expected) begin
        $display("ERROR: a=%d b=%d op=%b | expected=%d got=%d",
                 t_a, t_b, t_op, expected, t_result);
        errors = errors + 1;
      end
      else begin
        $display("PASS:  a=%d b=%d op=%b | result=%d",
                 t_a, t_b, t_op, t_result);
      end
    end
  endtask

  initial begin
    errors = 0;

    // --------------------------------------------------
    // Addition tests
    // --------------------------------------------------
    t_op = 0;

    t_a = 4; t_b = 3;
    check(7);

    t_a = 7; t_b = 2;
    check(9);

    // --------------------------------------------------
    // Subtraction tests
    // --------------------------------------------------
    t_op = 1;

    t_a = 7; t_b = 3;
    check(4);

    t_a = 9; t_b = 2;
    check(7);

    // --------------------------------------------------
    // Switch operation with SAME operands
    // --------------------------------------------------
    t_a = 6;
    t_b = 2;

    t_op = 0;
    check(8);

    t_op = 1;
    check(4);

    // --------------------------------------------------
    // Change operands while staying in subtraction
    // --------------------------------------------------
    t_op = 1;

    t_a = 8; t_b = 3;
    check(5);

    t_a = 10; t_b = 4;
    check(6);

    t_a = 12; t_b = 5;
    check(7);

    // --------------------------------------------------
    // Final result
    // --------------------------------------------------
    if (errors == 0)
      $display("PASS: All ALU tests passed.");
    else
      $display("FAIL: %0d errors found.", errors);

    $finish;
  end

endmodule