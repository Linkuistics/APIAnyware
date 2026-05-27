//! Racket enum file code generation.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::Enum;

/// Generate a Racket enums file for a framework.
pub fn generate_enums_file(enums: &[Enum], framework: &str) -> String {
    let mut w = CodeWriter::new();
    w.line("#lang racket/base");
    write_line!(w, ";; Generated enum definitions for {}", framework);
    w.blank_line();
    w.line("(provide (all-defined-out))");
    w.blank_line();

    for en in enums {
        write_line!(w, ";; {}", en.name);
        for v in &en.values {
            write_line!(w, "(define {} {})", v.name, v.value);
        }
        w.blank_line();
    }

    w.finish()
}
