# frozen_string_literal: true

module ImageMagic
  def image_magic(input, action)
    @context.registers[:image_magic] ||= {}

    image = if @context.registers[:image_magic][input]
              @context.registers[:image_magic][input]
            else
              attachment = @context.registers[:template].attachments.detect { |a| a.blob.filename == input }
              @context.registers[:image_magic][input] = Img2Zpl::Image.read(attachment.download)
            end

    operation, params = action.split(':')
    result = if operation
               if params
                 image.send(operation.to_sym, params)
               else
                 image.send(operation.to_sym)
               end
             end
    if result.instance_of?(String)
      result
    else
      @context.registers[:image_magic][input] = result
      input
    end
  end
end

Liquid::Template.register_filter(ImageMagic)
