@Grab('org.apache.poi:poi-ooxml:5.2.5')
@Grab('org.apache.logging.log4j:log4j-slf4j2-impl:2.23.1')
import org.apache.poi.xwpf.usermodel.XWPFDocument
import org.apache.poi.xwpf.usermodel.XWPFStyle

import java.nio.file.Files
import java.nio.file.Path

XWPFDocument doc = new XWPFDocument(new FileInputStream(new File('src/groovy/template.docx')))

XWPFStyle testStyle = doc.styles.getStyleWithName('TestStyle')
assert testStyle != null
println testStyle.styleId

doc.paragraphs.each { p ->
    if (p.text == '<jvmLanguages>') {
        def pPos = doc.getPosOfParagraph(p)
        doc.removeBodyElement(pPos)

        def languages = Files.readAllLines(Path.of('src/include/jvmLanguages.asciidoc')).join('\n')
        def lp = doc.createParagraph()
        lp.style = testStyle.styleId
        def run = lp.createRun()
        run.textPosition = pPos
        run.text = languages
    }
}

def out = new FileOutputStream(new File('src/groovy/out.docx'))
doc.write(out)
out.close()
doc.close()
