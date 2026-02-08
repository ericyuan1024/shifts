"use client";

type Option = {
  value: string;
  label: string;
};

type Props = {
  formId: string;
  name: string;
  defaultValue: string;
  options: Option[];
  className?: string;
  disabled?: boolean;
};

export default function AutoSubmitSelect({
  formId,
  name,
  defaultValue,
  options,
  className,
  disabled,
}: Props) {
  const isPlaceholder = defaultValue === "";
  return (
    <select
      name={name}
      defaultValue={defaultValue}
      className={className}
      disabled={disabled}
      onChange={() => {
        const form = document.getElementById(formId) as HTMLFormElement | null;
        form?.requestSubmit();
      }}
    >
      {options.map((option) => (
        <option
          key={option.value}
          value={option.value}
          disabled={option.value === "" && !isPlaceholder}
        >
          {option.label}
        </option>
      ))}
    </select>
  );
}
